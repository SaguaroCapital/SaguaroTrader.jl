
include("qts.jl")

"""
Backtest trading simulation

Fields
------
- `start_dt::DateTime`
- `end_dt::DateTime`
- `pcm`
- `exec_handler`
- `rebalance`
- `start_tracking_dt::DateTime`
- `equity_curve::DataFrame`
"""
struct BacktestTradingSession
    start_dt::DateTime
    end_dt::DateTime
    pcm
    exec_handler
    rebalance
    start_tracking_dt::DateTime
    equity_curve::DataFrame
    function BacktestTradingSession(
        start_dt::DateTime,
        end_dt::DateTime,
        universe,
        broker,
        alpha_model,
        rebalance,
        portfolio_id::String,
        order_sizer,
        portfolio_optimizer;
        # risk_model, #TODO: Implement
        # signals, #TODO: Implement
        start_tracking_dt::Union{Nothing,DateTime}=nothing,
    )
        @assert portfolio_id in keys(broker.portfolios) "`portfolio_id` not found ($portfolio_id)"
        if isnothing(start_tracking_dt)
            start_tracking_dt = start_dt
        end
        pcm = PortfolioConstructionModel(
            broker, portfolio_id, universe, order_sizer, portfolio_optimizer, alpha_model
        )
        exec_handler = ExecutionHandler(broker, portfolio_id; submit_orders=true)
        initial_equity = total_equity(pcm.broker.portfolios[portfolio_id])
        equity_curve = DataFrame(;
            timestamp=Vector{DateTime}([start_dt]),
            total_equity=Vector{Float64}([initial_equity]),
        )
        return new(
            start_dt, end_dt, pcm, exec_handler, rebalance, start_tracking_dt, equity_curve
        )
    end
end

function _update_equity_curve!(trading_session::BacktestTradingSession, dt::DateTime)
    if dt >= trading_session.start_tracking_dt
        portfolio_id = trading_session.pcm.portfolio_id
        te = total_equity(trading_session.pcm.broker.portfolios[portfolio_id])
        new_row = DataFrame(; timestamp=[dt], total_equity=[te])
        append!(trading_session.equity_curve, new_row)
    end
    return trading_session.equity_curve
end

"""
```julia
_rebalance_and_execute!(trading_session::BacktestTradingSession, 
                        dt::DateTime)
```

Rebalance and execute orders

Parameters
----------
- `trading_session::BacktestTradingSession`
- `dt::DateTime`
"""
function _rebalance_and_execute!(trading_session::BacktestTradingSession, dt::DateTime)
    rebalance_orders = _create_rebalance_orders(trading_session.pcm, dt)
    trading_session.exec_handler(rebalance_orders)
    return nothing
end

function _is_rebalance(trading_session::BacktestTradingSession, dt::DateTime)
    return dt in trading_session.rebalance.rebalances
end

"""
Get the first rebalance event after
the planned rebalance period, if 
we do not have any events on the exact day/time.

WARNING: EVENT_TIMESTAMPS IS ASSUMED TO BE SORTED
"""
function _closest_event(event_timestamps::Vector, rebalance_dt::DateTime)
    max_dt = maximum(event_timestamps)
    if rebalance_dt > max_dt
        return max_dt # this event already happens, so we can return and ignore it
    else
        return event_timestamps[event_timestamps .>= rebalance_dt][1]
    end
end

"""
```julia
run!(trading_session::BacktestTradingSession)
```

Run a simulated trading session

Parameters
----------
- `trading_session::BacktestTradingSession`
- `rebalance_event::Symbol=:market_open`
"""
function run!(trading_session::BacktestTradingSession; rebalance_event::Symbol=:market_open)
    df_events = _get_unique_pricing_events(
        trading_session.pcm.broker.data_handler,
        trading_session.start_dt,
        trading_session.end_dt,
    )
    sort!(df_events, :timestamp)

    # add rebalances to df_events
    rebalance_events = [
        i for i in trading_session.rebalance.rebalances if i in df_events.timestamp
    ]
    potential_rebalances = df_events[df_events.event_type .== rebalance_event, :timestamp]
    missing_rebalances = [
        _closest_event(potential_rebalances, i) for
        i in trading_session.rebalance.rebalances if !(i in df_events.timestamp)
    ]
    df_rebalances = DataFrame(;
        timestamp=Vector{DateTime}([potential_rebalances..., missing_rebalances...])
    )
    df_rebalances[:, :event_type] .= :rebalance

    df_events = unique(vcat(df_events, df_rebalances))
    sort!(df_events, :timestamp)

    #TODO: Add signals
    for event in eachrow(df_events)
        dt = event.timestamp
        event_type = event.event_type
        if (event_type == rebalance_event) | (event_type == :rebalance)
            update_prices!(trading_session.pcm.broker, dt)
            if (dt in rebalance_events) | (event_type == :rebalance)
                _rebalance_and_execute!(trading_session, dt)
            end
            execute_orders!(trading_session.pcm.broker, dt)
        end

        if event_type == :market_close
            if dt >= trading_session.start_tracking_dt
                update_prices!(trading_session.pcm.broker, dt)
                _update_equity_curve!(trading_session, dt)
            end
        end
    end
end
