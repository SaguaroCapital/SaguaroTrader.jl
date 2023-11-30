
"""
Simlated broker for transacting assets

Fields
------
- `start_dt::DateTime`
- `current_dt::DateTime`
- `exchange`
- `data_handler::DataHandler`
- `account_id::String`
- `base_currency::String`
- `initial_cash::Float64`
- `fee_model`
- `cash_balances::Dict{String,Float64}`
- `portfolios::Dict{String,Portfolio}`
- `open_orders::Dict{String,Queue{Order}}`
"""
mutable struct SimulatedBroker <: Broker
    start_dt::DateTime
    current_dt::DateTime
    exchange
    data_handler::DataHandler
    account_id::String
    base_currency::String
    initial_cash::Float64
    fee_model
    slippage_model
    # market_impact_model::AbstractMarketImpactModel # TODO: Implement
    cash_balances::Dict{String,Float64}
    portfolios::Dict{String,Portfolio}
    open_orders::Dict{String,Queue{Order}}

    function SimulatedBroker(
        start_dt::DateTime,
        exchange,
        data_handler::DataHandler;
        account_id::String="",
        base_currency::String="USD",
        initial_cash::Float64=0.0,
        fee_model=ZeroFeeModel(),
        slippage_model=ZeroSlippageModel(),
    )
        @assert initial_cash >= 0.0 "initial cash must be >= 0"

        cash_balances = Dict{String,Float64}(base_currency => initial_cash)
        portfolios = Dict{String,Portfolio}()
        open_orders = Dict{String,Queue{Order}}()

        return new(
            start_dt,
            start_dt,
            exchange,
            data_handler,
            account_id,
            base_currency,
            initial_cash,
            fee_model,
            slippage_model,
            cash_balances,
            portfolios,
            open_orders,
        )
    end
end

function subscribe_funds!(broker, amount::Real)
    @assert amount >= 0 "Can not credit negative amount: $amount"
    return broker.cash_balances[broker.base_currency] += amount
end

function subscribe_funds!(broker, amount::Real, currency::String)
    @assert amount >= 0 "Can not credit negative amount: $amount"
    return broker.cash_balances[currency] += amount
end

function withdraw_funds!(broker, amount::Real)
    @assert amount >= 0 "Can not debit negative amount: $amount"
    error_msg = "Can not withdraw $amount, because it is more than the cash balance of $(broker.cash_balances[broker.base_currency])"
    @assert amount <= broker.cash_balances[broker.base_currency] error_msg

    return broker.cash_balances[broker.base_currency] -= amount
end

function withdraw_funds!(broker, amount::Real, currency::String)
    @assert amount >= 0 "Can not debit negative amount: $amount"
    @assert currency in keys(broker.cash_balances) "Unknown currency $currency"
    error_msg = "Can not withdraw $amount, because it is more than the cash balance of $(broker.cash_balances[currency])"
    @assert amount <= broker.cash_balances[currency] error_msg

    return broker.cash_balances[currency] -= amount
end

function get_total_market_value(broker)
    tmv = 0.0
    for (portfolio_id, portfolio) in broker.portfolios
        tmv += total_market_value(portfolio)
    end
    return tmv
end

function get_account_total_equity(broker)
    te = 0.0
    for (portfolio_id, portfolio) in broker.portfolios
        te += total_equity(portfolio)
    end
    return te
end

function create_portfolio!(
    broker, initial_cash::Real; name::String="", portfolio_id::String=string(UUIDs.uuid1())
)
    error_msg = "Not enough cash in the broker $(broker.cash_balances[broker.base_currency])"
    @assert initial_cash <= broker.cash_balances[broker.base_currency] error_msg
    @assert initial_cash >= 0.0 "initial cash must be >= 0"
    p = Portfolio(
        broker.current_dt,
        float(initial_cash),
        broker.base_currency;
        portfolio_id=portfolio_id,
        name=name,
    )
    broker.portfolios[portfolio_id] = p
    broker.open_orders[portfolio_id] = Queue{Order}()
    broker.cash_balances[broker.base_currency] -= initial_cash

    return p
end

function create_portfolio!(
    broker; name::String="", portfolio_id::String=string(UUIDs.uuid1())
)
    p = Portfolio(
        broker.current_dt,
        broker.cash_balances[broker.base_currency],
        broker.base_currency;
        portfolio_id=portfolio_id,
        name=name,
    )
    broker.portfolios[portfolio_id] = p
    broker.open_orders[portfolio_id] = Queue{Order}()
    broker.cash_balances[broker.base_currency] = 0.0

    return p
end

function subscribe_funds_to_portfolio!(broker, portfolio_id::String, amount::Real)
    @assert amount >= 0.0 "Unable to add negative amount $amount to a portfolio"
    @assert any(portfolio_id .== keys(broker.portfolios)) "The porfolio ID $portfolio_id does not exist"
    @assert amount <= broker.cash_balances[broker.base_currency] "Not enough funds in broker ($(broker.cash_balances[broker.base_currency])) to fund portfolio $amount"
    subscribe_funds!(broker.portfolios[portfolio_id], broker.current_dt, float(amount))
    broker.cash_balances[broker.base_currency] -= amount

    return nothing
end

function withdraw_funds_from_portfolio!(broker, portfolio_id::String, amount::Real)
    @assert amount >= 0.0 "Unable to withdraw negative amount $amount to a portfolio"
    @assert any(portfolio_id .== keys(broker.portfolios)) "The porfolio ID $portfolio_id does not exist"
    @assert amount <= broker.portfolios[portfolio_id].cash "Not enough funds in portfollio ($(broker.portfolios[portfolio_id].cash)) to withdraw $amount"
    withdraw_funds!(broker.portfolios[portfolio_id], broker.current_dt, float(amount))
    broker.cash_balances[broker.base_currency] += amount

    return nothing
end

"""
Execute order, and create transaction
"""
function _execute_order(broker, dt::DateTime, portfolio_id::String, order)
    bid_ask = get_asset_latest_bid_ask_price(broker.data_handler, dt, order.asset.symbol)
    volume = get_asset_latest_volume(broker.data_handler, dt, order.asset.symbol)

    if bid_ask === (missing, missing)
        error(
            "Unable to obtain a latest market price for $(order.asset)",
            "$(order.order_id) was not executed",
        )
    end

    if order.direction > 0 # buy
        price = bid_ask[2]
    else # sell
        price = bid_ask[1]
    end
    price = broker.slippage_model(
        order.direction; price, volume, order_quantity=order.quantity
    )

    consideration = round(price * order.quantity; digits=2)
    fee = calculate_fee(broker.fee_model, order.quantity, price)
    est_total_cost = consideration + fee
    total_cash = broker.portfolios[portfolio_id].cash

    # Check that sufficient cash exists to carry out the
    # order, else scale it down
    quantity = copy(order.quantity)
    if est_total_cost > total_cash
        while (est_total_cost > total_cash) & (quantity > 0)
            quantity -= 1
            consideration = round(price * quantity; digits=2)
            fee = calculate_fee(broker.fee_model, quantity, price)
            est_total_cost = consideration + fee
            total_cash = broker.portfolios[portfolio_id].cash
        end
        if quantity == 0
            error_msg = """
                Unable execute order. Not enough cash for any shares.
                Total Cash: $total_cash
                Share Price: $price
                Asset: $(order.asset)
            """
            error(error_msg)
        end
    end

    txn = Transaction(order.asset, quantity, broker.current_dt, price, fee, order.order_id)
    return transact_asset!(broker.portfolios[portfolio_id], txn)
end

"""
Add an order to the broker order queue
"""
function submit_order!(broker, portfolio_id::String, order)
    @assert any(portfolio_id .== keys(broker.portfolios)) "The porfolio ID $portfolio_id does not exist"
    return enqueue!(broker.open_orders[portfolio_id], order)
end

"""
```julia
update!(broker, dt::DateTime; exec_orders::Bool=true)
```

Updates the current SimulatedBroker timestamp.

Updates portfolio asset values.

Attempts to execute open orders.
"""
function update!(broker, dt::DateTime)
    broker.current_dt = dt
    update_prices!(broker, dt)
    execute_orders!(broker, dt)
    return nothing
end

function update_prices!(broker, dt::DateTime)
    for portfolio_id in keys(broker.portfolios)
        assets = keys(broker.portfolios[portfolio_id].pos_handler.positions)
        for asset in assets
            mid_price = get_asset_latest_mid_price(broker.data_handler, dt, asset)
            if mid_price == 0.0
                error("Zero Price for $asset at $dt")
            end
            update_current_price!(
                broker.portfolios[portfolio_id].pos_handler.positions[asset], mid_price
            )
        end
    end
    return nothing
end

function execute_orders!(broker, dt::DateTime)
    if is_open(broker.exchange, dt)
        for portfolio_id in keys(broker.open_orders)
            while length(broker.open_orders[portfolio_id]) > 0
                order = first(broker.open_orders[portfolio_id])
                _execute_order(broker, dt, portfolio_id, order)
                dequeue!(broker.open_orders[portfolio_id])
            end
        end
    end
    return nothing
end

"""
```julia
function create_portfolio!(
    broker,
    initial_cash::Real;
    name::String = "",
    portfolio_id::String = string(UUIDs.uuid1()),
)
```

```julia
function create_portfolio!(
    broker;
    name::String = "",
    portfolio_id::String = string(UUIDs.uuid1()),
)
```

Create a portolio using the broker's cash balance
to fund the initial capital.

Parameters
----------
- `broker`
- `initial_cash::Real`
- `name::String = ""`
- `portfolio_id::String = string(UUIDs.uuid1())`
"""
create_portfolio!

"""
```julia
subscribe_funds!(broker, amount::Real)
```

```julia
subscribe_funds!(broker, amount::Real, currency::String)
```

Add funds to broker

Parameters
----------
- `broker`
- `amount::Real`
- `currency::String`
"""
subscribe_funds!

"""
```julia
withdraw_funds!(broker, amount::Real)
```

```julia
withdraw_funds!(broker, amount::Real, currency::String)
```

Withdraw funds from broker

Parameters
----------
- `broker`
- `amount::Real`
- `currency::String`
"""
withdraw_funds!

"""
```julia
subscribe_funds_to_portfolio!(broker, portfolio_id::String, amount::Real)
```

Add funds to portfolio from the broker

Parameters
----------
- `broker`
- `portfolio_id::String`
- `amount::Real`
"""
subscribe_funds_to_portfolio!

"""
```julia
withdraw_funds_from_portfolio!(broker, portfolio_id::String, amount::Real)
```

Withdraw funds from portfolio into the broker

Parameters
----------
- `broker`
- `portfolio_id::String`
- `amount::Real`
"""
withdraw_funds_from_portfolio!
