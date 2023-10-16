
"""
Abstract type for asset universes
"""
abstract type Universe end

"""
Static asset universe

Parameters
----------
- `assets`
"""
struct StaticUniverse <: Universe
    assets
end

"""
Dynamic asset universe. Each asset has a start date

Parameters
----------
- `asset_dates::Vector{Dict{Symbol,DateTime}}`
"""
struct DynamicUniverse <: Universe
    asset_dates::Dict{Asset,DateTime}
end

function _get_assets(uni::StaticUniverse)
    return uni.assets
end

"""
```julia
_get_assets(uni::DynamicUniverse, dt)
```

Assert if two orders are the same (other than the id)

Parameters
----------
- `uni::DynamicUniverse`
- `dt` datetime for asset universe

Returns
-------
- `Vector{Asset}`
"""
function _get_assets(uni::DynamicUniverse, dt)::Vector{Asset}
    return Vector{Asset}([
        asset for (asset, asset_date) in uni.asset_dates if asset_date < dt
    ])
end
