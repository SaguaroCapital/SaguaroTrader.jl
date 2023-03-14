
"""
Rebalance monthly

Fields
------
- `start_date::Date`
- `end_date::Date`
- `market_time::DateTime`
- `rebalances::Vector{DateTime}`
"""
struct MonthlyRebalance <: Rebalance
    start_date::Date
    end_date::Date
    market_time::Union{Hour,Minute,Dates.CompoundPeriod}
    rebalances::Vector{DateTime}
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
