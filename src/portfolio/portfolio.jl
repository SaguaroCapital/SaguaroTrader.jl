
include("transaction.jl")
include("position.jl")
include("position_handler.jl")
include("portfolio_event.jl")

"""
Portfolio

Fields
------
- `current_dt::DateTime`
- `cash::Float64`
- `currency::String`
- `pos_handler::PositionHandler`
- `portfolio_id::String`
- `name::String`
- `history::Vector{PortfolioEvent}`
"""
mutable struct Portfolio
    current_dt::DateTime
    cash::Float64
    currency::String
    pos_handler::PositionHandler
    portfolio_id::String
    name::String
    history::Vector{PortfolioEvent}
    function Portfolio(
        start_dt::DateTime,
        starting_cash::Float64,
        currency::String;
        portfolio_id::String=string(UUIDs.uuid1()),
        name::String="",
    )
        # if we have starting cash, create a subscription event
        if starting_cash > 0.0
            sub = create_subscription(start_dt, starting_cash, starting_cash)
            history = [sub]
        else
            history = Vector{PortfolioEvent}()
        end

        pos_handler = PositionHandler(Dict{Symbol,Position}())

        return new(
            start_dt, starting_cash, currency, pos_handler, portfolio_id, name, history
        )
    end
end

"""
```julia
total_market_value(port::Portfolio)
```

Total market value of the portfolio excluding cash.

Parameters
----------
- `ord1::Order`
- `ord2::Order`

Returns
-------
- `Float64`
"""
function total_market_value(port::Portfolio)
    return total_market_value(port.pos_handler)
end

"""
```julia
total_equity(port::Portfolio)
```

Total market value of the portfolio including cash.

Parameters
----------
- `ord1::Order`
- `ord2::Order`

Returns
-------
- `Float64`
"""
function total_equity(port::Portfolio)
    return total_market_value(port.pos_handler) + port.cash
end

function total_unrealized_pnl(port::Portfolio)
    return total_unrealized_pnl(port.pos_handler)
end

function total_realized_pnl(port::Portfolio)
    return total_realized_pnl(port.pos_handler)
end

function total_pnl(port::Portfolio)
    return total_pnl(port.pos_handler)
end

function subscribe_funds!(port::Portfolio, dt::DateTime, amount::Real)
    if dt < port.current_dt
        error(
            "Subscription datetime $dt is earlier",
            "than current portfolio datetime $(port.current_dt)",
            "Cannot subscribe funds.",
        )
    elseif amount < 0.0
        error("Cannot credit negative amount: $amount")
    end

    port.current_dt = dt
    port.cash += amount

    pe = create_subscription(dt, amount, port.cash)
    append!(port.history, [pe])

    return nothing
end

function withdraw_funds!(port::Portfolio, dt::DateTime, amount::Float64)
    if dt < port.current_dt
        error(
            "Withdrawal datetime $dt is earlier",
            "than current portfolio datetime $(port.current_dt)",
            "Cannot withdraw funds.",
        )
    elseif amount < 0.0
        error("Cannot debit negative amount: $amount")
    elseif amount > port.cash
        error("Not enough cash in the portfolio ($(port.cash))", "to withdraw $amount.")
    end

    port.current_dt = dt
    port.cash -= amount

    pe = create_withdrawal(dt, amount, port.cash)
    append!(port.history, [pe])

    return nothing
end

function transact_asset!(port::Portfolio, txn::Transaction)
    if txn.dt < port.current_dt
        error(
            "Transaction datetime $(txn.dt) is earlier",
            "than current portfolio datetime $(port.current_dt)",
            "Cannot transact asset.",
        )
    end

    txn_share_cost = txn.price * txn.quantity
    txn_total_cost = txn_share_cost + txn.fee

    if txn_total_cost > port.cash
        @warn "Negative cash balance: $(port.cash)."
    end

    port.current_dt = txn.dt
    port.cash -= cost_with_fee(txn)

    transact_position!(port.pos_handler, txn)
    pe = create_asset_transaction(txn.dt, abs(txn_total_cost), port.cash, direction(txn))
    append!(port.history, [pe])

    return nothing
end

"""
```julia
_get_assets(port::Portfolio)
```

Get a vector of all assets in the universe

Parameters
----------
- `port::Portfolio`

Returns
-------
- `Float64`
"""
function _get_assets(port::Portfolio)
    return [i[2].asset for i in port.pos_handler.positions]
end
