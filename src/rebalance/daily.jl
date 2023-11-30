
"""
Rebalance daily

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct DailyRebalance <: Rebalance
    start_date::Date
    end_date::Date
    market_time::Union{Hour,Minute,Dates.CompoundPeriod}
    rebalances::AbstractVector{DateTime}
    function DailyRebalance(
        start_date::Date,
        end_date::Date,
        market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) + Minute(30),
    )
        n_days = (end_date - start_date).value
        start_dt = DateTime(start_date) .+ market_time
        rebalances = [start_dt + Day(i) for i in 0:n_days]
        return new(start_date, end_date, market_time, rebalances)
    end

    function DailyRebalance(
        start_date::DateTime,
        end_date::DateTime,
        market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) + Minute(30),
    )
        return DailyRebalance(Date(start_date), Date(end_date), market_time)
    end
end
