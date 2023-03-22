
"""
abstract type for slippage models
"""
abstract type SlippageModel end

#TODO: Investigate integration of more advanced bid/ask spread methods
# https://github.com/eguidotti/bidask

"""
Fixed spread for all assets

Buy orders will execute at `ask + spread / 2`
Sell orders will execute at `bid - spread / 2`

Fields
------
- `spread::Float64`
"""
struct FixedSlippageModel <: SlippageModel
    spread::Float64
end

function (slippage_model::FixedSlippageModel)(order::Order, price::Float64)
    return price + (slippage_model.spread / 2.0) * order.direction
end

"""
Spread is a percent of the asset price

Buy orders will execute at `ask * (1 + (slippage_pct/100))`
Sell orders will execute at `bid * (1 - (slippage_pct/100))`

Fields
------
- `slippage_pct::Float64`
"""
struct PercentSlippageModel <: SlippageModel
    slippage_pct::Float64
end

function (slippage_model::PercentSlippageModel)(order::Order, price::Float64)
    return price + ((slippage_model.slippage_pct / 100) * price / 2.0) * order.direction
end

#TODO: Implement
# Need to carry volume information through to the model
"""

"""
struct VolumeSharesSlippageModel <: SlippageModel end
