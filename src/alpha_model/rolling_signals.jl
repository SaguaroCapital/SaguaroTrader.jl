
"""
Signals that change through time. Produces the most recent
signal at a given time

Fields
------
- `dict_signal_weights::Dict{DateTime, Dict{Asset,Float64}}`
"""
struct RollingSignalsAlphaModel <: AlphaModel
    dict_signal_weights::Dict{DateTime,Dict{Asset,Float64}}
end

function (alpha_model::RollingSignalsAlphaModel)(dt)
    k = [i for i in keys(alpha_model.dict_signal_weights)]
    key_mask = k .<= dt
    if sum(key_mask) == 0 # no signal before the current time
        @warn "No signal given before $dt"
        return Dict{Asset,Float64}()
    else
        most_recent_key = maximum(k[key_mask])
        return alpha_model.dict_signal_weights[most_recent_key]
    end
end
