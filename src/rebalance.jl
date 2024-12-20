
"""
Rebalance periods for backtesting
"""
abstract type AbstractRebalance end

function _is_rebalance_event(rebalance::AbstractRebalance, dt::DateTime)
    return dt in rebalance.rebalances
end

############################################################
# buy and hold
############################################################
"""
Only rebalance at the start date

Fields
------
- `start_dt::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct BuyAndHoldRebalance <: AbstractRebalance
    start_date::DateTime
    end_date::DateTime
    rebalances::AbstractVector{DateTime}
    function BuyAndHoldRebalance(start_dt::DateTime)
        return new(Date(start_dt), Date(start_dt), [start_dt])
    end
    function BuyAndHoldRebalance(
        start_date::Date,
        market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) + Minute(30),
    )
        start_dt = DateTime(start_date) .+ market_time
        return new(start_date, start_date, [start_dt])
    end
end

############################################################
# daily
############################################################

"""
Rebalance daily

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct DailyRebalance <: AbstractRebalance
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

############################################################
# weekly
############################################################

"""
Rebalance weekly

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct WeeklyRebalance <: AbstractRebalance
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

############################################################
# monthly
############################################################

"""
Rebalance monthly

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct MonthlyRebalance <: AbstractRebalance
    start_date::Date
    end_date::Date
    market_time::Union{Hour,Minute,Dates.CompoundPeriod}
    rebalances::AbstractVector{DateTime}
    function MonthlyRebalance(
        start_date::Date,
        end_date::Date,
        day_of_month::Int=1,
        market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) + Minute(30),
    )
        # adjust start month based on day of month
        if (Day(start_date) <= Day(day_of_month)) & (day_of_month >= 1)
            adjusted_start_date = Date(Year(start_date).value, Month(start_date).value)
        else
            adjusted_start_date = Date(Year(start_date).value, Month(start_date).value + 1)
        end

        # day adjustment
        if day_of_month >= 1
            adjusted_start_date = adjusted_start_date + Day(day_of_month - 1)
        else
            adjusted_start_date = adjusted_start_date + Day(day_of_month)
        end

        # generate rebalances
        start_dt = DateTime(adjusted_start_date) .+ market_time
        current_dt = start_dt
        rebalances = Vector{DateTime}()
        while Date(current_dt) <= end_date
            push!(rebalances, current_dt)
            current_dt = current_dt .+ Month(1)
        end
        return new(adjusted_start_date, end_date, market_time, rebalances)
    end
end
