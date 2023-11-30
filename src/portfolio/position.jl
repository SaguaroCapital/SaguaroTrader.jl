"""
Handles the accounting of a position in an asset.

Fields
------
- `asset::Symbol`
- `current_price::Float64`
- `current_dt::DateTime`
- `buy_quantity::Float64`
- `sell_quantity::Float64`
- `net_quantity::Float64`
- `avg_bought::Float64`
- `avg_sold::Float64`
- `buy_fee::Float64`
- `sell_fee::Float64`
"""
mutable struct Position
    asset::Asset
    current_price::Float64
    current_dt::DateTime
    buy_quantity::Float64
    sell_quantity::Float64
    net_quantity::Float64
    avg_bought::Float64
    avg_sold::Float64
    buy_fee::Float64
    sell_fee::Float64
end

"""
```julia
position_from_transaction(txn::Transaction)::Position
```

Create a position using a transaction

Parameters
----------
- `txn::Transaction`

Returns
-------
- `Position`
"""
function position_from_transaction(txn::Transaction)
    dir::Int = direction(txn)
    if dir == 1
        buy_quantity = txn.quantity
        sell_quantity = 0.0
        avg_bought = txn.price
        avg_sold = 0.0
        net_quantity = txn.quantity
        buy_fee = txn.fee
        sell_fee = 0.0
    else
        buy_quantity = 0.0
        sell_quantity = abs(txn.quantity)
        avg_bought = 0.0
        avg_sold = txn.price
        net_quantity = txn.quantity
        buy_fee = 0.0
        sell_fee = txn.fee
    end

    return Position(txn.asset,
                    txn.price,
                    txn.dt,
                    buy_quantity,
                    sell_quantity,
                    net_quantity,
                    avg_bought,
                    avg_sold,
                    buy_fee,
                    sell_fee)
end

"""
```julia
direction(pos::Position)
```

Calculate the direction of the position (long/short).

Parameters
----------
- `pos::Position`

Returns
-------
- `Int`: Long=1, Short=-1
"""
function direction(pos::Position)
    return Int(sign(pos.net_quantity)::Float64)::Int
end

"""
```julia
market_value(pos::Position)
```

Market value of the position based on the 
current price of the position

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`: Current market value of the position
"""
function market_value(pos::Position)
    return pos.current_price * pos.net_quantity
end

"""
```julia
market_value(pos::Position)
```

Average price paid for all assets on buy/sell side

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`: Average price
"""
function avg_price(pos::Position)
    if pos.net_quantity == 0
        return 0.0
    elseif pos.net_quantity > 0
        return (pos.avg_bought * pos.buy_quantity + pos.buy_fee) / pos.buy_quantity
    else
        return (pos.avg_sold * pos.sell_quantity - pos.sell_fee) / pos.sell_quantity
    end
end

"""
```julia
net_quantity(pos::Position)
```

Net quantity of bought/sold of an asset

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function net_quantity(pos::Position)
    return pos.buy_quantity - pos.sell_quantity
end

"""
```julia
total_bought(pos::Position)
```

Total cost of assets currently purchased

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function total_bought(pos::Position)
    return pos.buy_quantity * pos.avg_bought
end

"""
```julia
total_sold(pos::Position)
```

Total cost of assets currently sold

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function total_sold(pos::Position)
    return pos.sell_quantity * pos.avg_sold
end

"""
```julia
net_total(pos::Position)
```

Net total average cost of assets
bought and sold.

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function net_total(pos::Position)
    return total_sold(pos) - total_bought(pos)
end

"""
```julia
net_incl_fee(pos::Position)
```
Net total average cost of assets bought
and sold including the fee.

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function net_incl_fee(pos::Position)
    return net_total(pos) - (pos.sell_fee + pos.buy_fee)
end

"""
```julia
realized_pnl(pos::Position)
```

Realized profit and loss

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function realized_pnl(pos::Position)
    dir = direction(pos)

    if dir == 1 # long
        if pos.sell_quantity == 0
            return 0.0
        else
            sell_pl = (pos.avg_sold - pos.avg_bought) * pos.sell_quantity
            buy_fee = (pos.sell_quantity / pos.buy_quantity) * pos.buy_fee
            return sell_pl - buy_fee - pos.sell_fee
        end
    elseif dir == -1
        if pos.buy_quantity == 0
            return 0.0
        else
            sell_pl = (pos.avg_sold - pos.avg_bought) * pos.sell_quantity
            sell_fee = (pos.buy_quantity / pos.sell_quantity) * pos.sell_fee
            return sell_pl - sell_fee - pos.buy_fee
        end
    else
        return net_incl_fee(pos)
    end
end

"""
```julia
unrealized_pnl(pos::Position)
```

Unrealized profit and loss

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function unrealized_pnl(pos::Position)
    return (pos.current_price - avg_price(pos)) * pos.net_quantity
end

"""
```julia
total_pnl(pos::Position)
```

Sum of the unrealized and realized profit and loss

Parameters
----------
- `pos::Position`

Returns
-------
- `Float64`
"""
function total_pnl(pos::Position)
    return realized_pnl(pos) + unrealized_pnl(pos)
end

function update_current_price!(pos::Position, market_price::Float64)
    if market_price <= 0.0
        println(pos)
        error("Market price $market_price must be positive to update the position.")
    else
        pos.current_price = market_price
    end
end

function update_current_price!(pos::Position, market_price::Float64, dt::DateTime)
    if pos.current_dt > dt
        error("Supplied time of $dt is earlier than the current time of $(pos.current_dt)")
    else
        pos.current_dt = dt
    end
    return update_current_price!(pos, market_price)
end

function buy!(pos::Position, quantity::Float64, price::Float64, fee::Float64)
    pos.avg_bought = ((pos.avg_bought * pos.buy_quantity) + (quantity * price)) /
                     (pos.buy_quantity + quantity)
    pos.buy_quantity += quantity
    return pos.buy_fee += fee
end

function sell!(pos::Position, quantity::Float64, price::Float64, fee::Float64)
    pos.avg_sold = ((pos.avg_sold * pos.sell_quantity) + (quantity * price)) /
                   (pos.sell_quantity + quantity)
    pos.sell_quantity += quantity
    return pos.sell_fee += fee
end

"""
```julia
transact!(pos::Position, txn::Transaction)
```

Buy/sell shares in a position

Parameters
----------
- `pos::Position`
- `txn::Transaction`
"""
function transact!(pos::Position, txn::Transaction)
    @assert txn.asset == pos.asset "Transaction asset $(txn.asset) != pos asset $(pos.asset)"

    # skip transaction if quanitty is 0
    if txn.quantity == 0
        return nothing
    end

    dir = direction(txn)::Int
    if dir == 1
        buy!(pos, txn.quantity, txn.price, txn.fee)
    else
        sell!(pos, abs(txn.quantity), txn.price, txn.fee)
    end

    update_current_price!(pos, txn.price, txn.dt)
    pos.current_dt = txn.dt
    pos.net_quantity = net_quantity(pos)::Float64

    return pos
end
