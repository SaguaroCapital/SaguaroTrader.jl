
"""
Rebalance weekly

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct WeeklyRebalance <: Rebalance
    start_date::Date
    end_date::Date
    market_time::Union{Hour,Minute,Dates.CompoundPeriod}
    rebalances::AbstractVector{DateTime}
    function WeeklyRebalance(
        start_date::Date,
        end_date::Date,
        day_of_week::Int=1, # monday
        market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) + Minute(30),
    )
        # adjust start day based on day of week
        start_day_of_week = dayofweek(start_date)
        if day_of_week == start_day_of_week
            day_adjustment = 0
        elseif day_of_week < start_day_of_week
            day_adjustment = 7 - (start_day_of_week - day_of_week)
        else
            day_adjustment = day_of_week - start_day_of_week
        end
        adjusted_start_date = start_date .+ Day(day_adjustment)

        # generate rebalances
        start_dt = DateTime(adjusted_start_date) .+ market_time
        current_dt = start_dt
        rebalances = Vector{DateTime}()
        while Date(current_dt) <= end_date
            push!(rebalances, current_dt)
            current_dt = current_dt .+ Week(1)
        end
        return new(adjusted_start_date, end_date, market_time, rebalances)
    end
end
