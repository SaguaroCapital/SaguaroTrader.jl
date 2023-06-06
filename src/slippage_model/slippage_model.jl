
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

function (slippage_model::ZeroSlippageModel)(
    direction::Int; price::Float64=0.0, volume::Float64=0.0
)
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

function (slippage_model::FixedSlippageModel)(
    direction::Int; price::Float64=0.0, volume::Float64=0.0
)
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

function (slippage_model::PercentSlippageModel)(
    direction::Int; price::Float64=0.0, volume::Float64=0.0
)
    return price + ((slippage_model.slippage_pct / 100) * price / 2.0) * direction
end

"""
Slippage is based on the ratio of order volume to total volume

Buy orders will execute at `ask * (1 + (volume_shares_pct/100) * order.volume / total_volume)`
Sell orders will execute at `bid * (1 - (volume_shares_pct/100) * order.volume / total_volume)`

Fields
------
- `volume_shares_pct::Float64`

Returns
-------
- `Float64`: The price including slippage
"""
struct VolumeSharesSlippageModel <: SlippageModel
    volume_shares_pct::Float64
end

function (slippage_model::VolumeSharesSlippageModel)(
    direction::Int; price::Float64=0.0, volume::Float64=0.0
)
    ratio = order.volume / volume
    return price + ((slippage_model.volume_shares_pct / 100) * price * ratio) * direction
end
