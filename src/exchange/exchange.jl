
"""
Abstract type for trading exchange
"""
abstract type Exchange end

"""
Simulate live trading

Fields
------
- `start_dt::DateTime`
- `open_time::Time=Time(14,30)`
- `close_time::Time=Time(21,00)`
"""
struct SimulatedExchange <: Exchange
    start_dt::DateTime
    open_time::Time
    close_time::Time
    function SimulatedExchange(
        start_dt; open_time::Time=Time(14, 30), close_time::Time=Time(21, 00)
    )
        return new(start_dt, open_time, close_time)
    end
end

function is_open(exchange::SimulatedExchange, dt::DateTime)
    if (dt > exchange.start_dt) &# check if the exchage is active
        (Time(dt) >= exchange.open_time) &
        (Time(dt) < exchange.close_time) #check if exchange is open
        return true
    else
        return false
    end
end

"""
Simulate an exchange that never closes

Fields
------
- `start_dt::DateTime`
"""
struct AlwaysOpenExchange <: Exchange
    start_dt::DateTime
end

function is_open(exchange::AlwaysOpenExchange, dt::DateTime)
    if (dt > exchange.start_dt)
        return true
    else
        return false
    end
end

"""
```julia
is_open(exc::Exchange, dt::DateTime)
```

Simulated Exchange:
- Check if an exchange is open. Using UTC, the NYSE is open from Time(14,30) to Time(21,00)


Parameters
----------
- `exchange::SimulatedExchange`
- `dt::DateTime`

Returns
-------
- `Bool`: true if the exchange is open at the given time
"""
is_open
