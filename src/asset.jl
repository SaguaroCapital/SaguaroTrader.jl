
"""
Metadata about an Asset
"""
abstract type AbstractAsset end

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
    assets::AbstractVector{AbstractAsset}
end

"""
Dynamic asset universe. Each asset has a start date

Parameters
----------
- `asset_dates::AbstractVector{Dict{Symbol,DateTime}}`
"""
struct DynamicUniverse <: Universe
    asset_dates::Dict{AbstractAsset,DateTime}
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
- `Vector{AbstractAsset}`
"""
function _get_assets(uni::DynamicUniverse, dt)::AbstractVector{AbstractAsset}
    return Vector{AbstractAsset}([
        asset for (asset, asset_date) in uni.asset_dates if asset_date < dt
    ])
end

"""
Equity asset type.

Fields
------
- `currency::String` - currency of the cash
"""
struct Cash <: AbstractAsset
    currency::String
    function Cash(currency::String="USD")
        return new(currency)
    end
end

"""
Equity asset type.

Fields
------
- `symbol::Symbol` - asset symbol
- `name::String` - name of the asset
- `tax_exempt::Bool=false` - asset tax exemption status
"""
struct Equity <: AbstractAsset
    symbol::Symbol
    name::String
    tax_exempt::Bool
    function Equity(symbol::Symbol, name::String, tax_exempt::Bool=false)
        return new(symbol, name, tax_exempt)
    end
    function Equity(symbol::Symbol, tax_exempt::Bool=false)
        return new(symbol, "$symbol", tax_exempt)
    end
end
