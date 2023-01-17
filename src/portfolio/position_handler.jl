
"""
Store all open positions
"""
struct PositionHandler
    positions::Dict{Symbol,Position}
    function PositionHandler(positions::Dict{Symbol,Position} = Dict{Symbol,Position}())
        return new(positions)
    end
end

"""
```julia
transact_position!(pos_handler::PositionHandler, txn::Transaction)
```

Buy/sell shares in a position

Parameters
----------
- `pos_handler::PositionHandler`
- `txn::Transaction`
"""
function transact_position!(pos_handler::PositionHandler, txn::Transaction)
    symbol::Symbol = txn.asset.symbol
    if symbol in keys(pos_handler.positions)
        transact!(pos_handler.positions[symbol], txn)
    else
        pos_handler.positions[symbol] = position_from_transaction(txn)
    end

    if pos_handler.positions[symbol].net_quantity == 0
        delete!(pos_handler.positions, symbol)
    end

    return pos_handler
end

"""
```julia
total_market_value(pos_handler::PositionHandler)
```

Total market value of all open positions

Parameters
----------
- `pos_handler::PositionHandler`

Returns
-------
- `Float64`
"""
function total_market_value(pos_handler::PositionHandler)
    market_value = 0.0
    for asset in keys(pos_handler.positions)
        pos = pos_handler.positions[asset]
        market_value += pos.current_price * pos.net_quantity
    end
    return market_value
end


"""
```julia
total_unrealized_pnl(pos_handler::PositionHandler)
```

Total unrealized pnl of all positions

Parameters
----------
- `pos_handler::PositionHandler`

Returns
-------
- `Float64`
"""
function total_unrealized_pnl(pos_handler::PositionHandler)
    upnl = 0.0
    for asset in keys(pos_handler.positions)
        pos = pos_handler.positions[asset]
        upnl += unrealized_pnl(pos)
    end
    return upnl
end

"""
```julia
total_realized_pnl(pos_handler::PositionHandler)
```

Total realized pnl of all positions

Parameters
----------
- `pos_handler::PositionHandler`

Returns
-------
- `Float64`
"""
function total_realized_pnl(pos_handler::PositionHandler)
    rpnl = 0.0
    for asset in keys(pos_handler.positions)
        pos = pos_handler.positions[asset]
        rpnl += realized_pnl(pos)
    end
    return rpnl
end


"""
```julia
total_realized_pnl(pos_handler::PositionHandler)
```

Totals pnl of all positions

Parameters
----------
- `pos_handler::PositionHandler`

Returns
-------
- `Float64`
"""
function total_pnl(pos_handler::PositionHandler)
    pnl = 0.0
    for asset in keys(pos_handler.positions)
        pos = pos_handler.positions[asset]
        pnl += total_pnl(pos)
    end
    return pnl
end
