
"""
Snapshot of the portfolio at a given time. 

Fields
------
- `dt::DateTime` 
- `type::String`
- `debit::Float64`
- `credit::Float64`
- `balance::Float64`
"""
struct PortfolioEvent
    dt::DateTime
    type::String
    debit::Float64
    credit::Float64
    balance::Float64
end

"""
```julia
create_subscription(dt::DateTime, credit::Float64, balance::Float64)
```

Create a subscription portolio event

Parameters
----------
- `dt::DateTime`
- `credit::Float64`
- `balance::Float64`

Returns
-------
- `PortfolioEvent`
"""
function create_subscription(dt::DateTime, credit::Float64, balance::Float64)
    return PortfolioEvent(
        dt, "subscription", 0.0, round(credit; digits=2), round(balance; digits=2)
    )
end

"""
```julia
create_withdrawal(dt::DateTime, credit::Float64, balance::Float64)
```

Create a withdrawal portolio event

Parameters
----------
- `dt::DateTime`
- `credit::Float64`
- `balance::Float64`

Returns
-------
- `PortfolioEvent`
"""
function create_withdrawal(dt::DateTime, debit::Float64, balance::Float64)
    return PortfolioEvent(
        dt, "withdrawal", round(debit; digits=2), 0.0, round(balance; digits=2)
    )
end

"""
```julia
create_asset_transaction(
    dt::DateTime,
    txn_total_cost::Float64,
    balance::Float64,
    direction::Int,
)
```

Create an asset buy/sell portfolio event

Parameters
----------
- `dt::DateTime`
- `txn_total_cost::Float64`
- `balance::Float64`
- `direction::Int`

Returns
-------
- `PortfolioEvent`
"""
function create_asset_transaction(
    dt::DateTime, txn_total_cost::Float64, balance::Float64, direction::Int
)
    credit = -1.0 * txn_total_cost
    if direction == 1
        type = "buy_asset"
    elseif direction == -1
        type = "sell_asset"
    end
    return PortfolioEvent(dt, type, 0.0, round(credit; digits=2), round(balance; digits=2))
end
