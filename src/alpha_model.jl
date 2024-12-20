
"""
Abstract type for alpha models
"""
abstract type AbstractAlphaModel end

function (alpha_model::AbstractAlphaModel)(dt)::Dict{AbstractAsset,Float64}
    return error("`get_signal` must be implemented for concrete AlphaModel types.")
end

############################################################
# fixed signals
############################################################
"""
A simple AlphaModel that provides a single scalar forecast
value for each Asset in the Universe.

Fields
------
- `signal_weights::Dict{AbstractAsset,Float64}`
"""
struct FixedSignalsAlphaModel <: AbstractAlphaModel
    signal_weights::Dict{AbstractAsset,Float64}
end

function (alpha_model::FixedSignalsAlphaModel)(dt)
    return alpha_model.signal_weights
end

############################################################
# rolling signals
############################################################
"""
Signals that change through time. Produces the most recent
signal at a given time

Fields
------
- `dict_signal_weights::Dict{DateTime, Dict{AbstractAsset,Float64}}`
"""
struct RollingSignalsAlphaModel <: AbstractAlphaModel
    dict_signal_weights::Dict{DateTime,Dict{AbstractAsset,Float64}}
end

function (alpha_model::RollingSignalsAlphaModel)(dt)
    k = [i for i in keys(alpha_model.dict_signal_weights)]
    key_mask = k .<= dt
    if sum(key_mask) == 0 # no signal before the current time
        @warn "No signal given before $dt"
        return Dict{AbstractAsset,Float64}()
    else
        most_recent_key = maximum(k[key_mask])
        return alpha_model.dict_signal_weights[most_recent_key]
    end
end

############################################################
# single signal
############################################################
"""
Fixed signal for all assets in the universe

Fields
------
- `universe`
- `signal::Float64`
"""
struct SingleSignalAlphaModel <: AbstractAlphaModel
    universe::Universe
    signal::Float64
end

function (alpha_model::SingleSignalAlphaModel)(dt)
    assets = _get_assets(alpha_model.universe)
    return Dict([asset => alpha_model.signal for asset in assets]...)
end
