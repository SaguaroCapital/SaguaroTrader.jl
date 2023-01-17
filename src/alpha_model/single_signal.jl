
"""
Fixed signal for all assets in the universe

Fields
------
- `universe::Universe`
- `signal::Float64`
"""
struct SingleSignalAlphaModel <: AlphaModel
    universe::Universe
    signal::Float64
end

function (alpha_model::SingleSignalAlphaModel)(dt)
    assets = _get_assets(alpha_model.universe)
    return Dict([asset => alpha_model.signal for asset in assets]...)
end
