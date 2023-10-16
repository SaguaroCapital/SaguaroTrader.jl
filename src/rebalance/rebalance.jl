
"""
Rebalance periods for backtesting
"""
abstract type Rebalance end

include("buy_and_hold.jl")
include("daily.jl")
include("weekly.jl")
include("monthly.jl")

function _is_rebalance_event(rebalance, dt::DateTime)
    return dt in rebalance.rebalances
end
