
"""
abstract type for slippage models
"""
abstract type SlippageModel end

#TODO: Investigate integration of more advanced bid/ask spread methods
# https://github.com/eguidotti/bidask

"""
A SlippageModel that produces no slippage.

Returns
-------
- `Float64`: The original price
"""
struct ZeroSlippageModel <: SlippageModel end

function (slippage_model::ZeroSlippageModel)(direction::Int; price::Float64=0.0,
                                             volume::Float64=0.0, order_quantity::Real=0.0)
    return price
end

"""
Fixed spread for all assets

Buy orders will execute at `ask + spread / 2`
Sell orders will execute at `bid - spread / 2`

Fields
------
- `spread::Float64`

Returns
-------
- `Float64`: The price including slippage
"""
struct FixedSlippageModel <: SlippageModel
    spread::Float64
end

function (slippage_model::FixedSlippageModel)(direction::Int; price::Float64=0.0,
                                              volume::Float64=0.0, order_quantity::Real=0.0)
    return price + (slippage_model.spread / 2.0) * direction
end

"""
Spread is a percent of the asset price

Buy orders will execute at `ask * (1 + (slippage_pct/100))`
Sell orders will execute at `bid * (1 - (slippage_pct/100))`

Fields
------
- `slippage_pct::Float64`

Returns
-------
- `Float64`: The price including slippage
"""
struct PercentSlippageModel <: SlippageModel
    slippage_pct::Float64
end

function (slippage_model::PercentSlippageModel)(direction::Int; price::Float64=0.0,
                                                volume::Float64=0.0,
                                                order_quantity::Real=0.0)
    return price + ((slippage_model.slippage_pct / 100) * price / 2.0) * direction
end

"""
Slippage is based on the ratio of order volume to total volume

Buy orders will execute at `ask + (volume_share^2 * price_impact * price * direction)`
Sell orders will execute at `bid - (volume_share^2 * price_impact * price * direction)`

Fields
------
- `price_impact::Float64=0.1` - The scaling coefficient for price impact. Larger values will result in larger price impacts.

Returns
-------
- `Float64`: The price including slippage
"""
struct VolumeSharesSlippageModel <: SlippageModel
    price_impact::Float64
end

function (slippage_model::VolumeSharesSlippageModel)(direction::Int; price::Float64=0.0,
                                                     volume::Float64=0.0,
                                                     order_quantity::Real=0.0)
    volume_share = order_quantity / volume
    simulated_impact = volume_share^2 * slippage_model.price_impact * price * direction
    return price + simulated_impact
end
