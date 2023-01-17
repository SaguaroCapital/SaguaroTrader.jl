
"""
Metadata about an Asset
"""
abstract type Asset end

include("universe.jl")

"""
Equity asset type.

Fields
------
- `currency::String` - currency of the cash
"""
struct Cash <: Asset
    currency::String
    function Cash(currency::String = "USD")
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
struct Equity <: Asset
    symbol::Symbol
    name::String
    tax_exempt::Bool
    function Equity(symbol::Symbol, name::String, tax_exempt::Bool = false)
        return new(symbol, name, tax_exempt)
    end
    function Equity(symbol::Symbol, tax_exempt::Bool = false)
        return new(symbol, "$symbol", tax_exempt)
    end
end
