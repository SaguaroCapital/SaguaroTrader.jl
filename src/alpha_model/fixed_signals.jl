
"""
A simple AlphaModel that provides a single scalar forecast
value for each Asset in the Universe.

Fields
------
- `signal_weights::Dict{Symbol,Float64}`
"""
struct FixedSignalsAlphaModel <: AlphaModel
    signal_weights::Dict{Asset,Float64}
end

function (alpha_model::FixedSignalsAlphaModel)(dt)
    return alpha_model.signal_weights
end
