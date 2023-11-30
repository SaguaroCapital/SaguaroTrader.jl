
"""
Only rebalance at the start date

Fields
------
- `start_dt::DateTime`
- `rebalances::AbstractVector{DateTime}`
"""
struct BuyAndHoldRebalance <: Rebalance
    start_date::DateTime
    end_date::DateTime
    rebalances::AbstractVector{DateTime}
    function BuyAndHoldRebalance(start_dt::DateTime)
        return new(Date(start_dt), Date(start_dt), [start_dt])
    end
    function BuyAndHoldRebalance(start_date::Date,
                                 market_time::Union{Hour,Minute,Dates.CompoundPeriod}=Hour(14) +
                                                                                      Minute(30))
        start_dt = DateTime(start_date) .+ market_time
        return new(start_date, start_date, [start_dt])
    end
end
