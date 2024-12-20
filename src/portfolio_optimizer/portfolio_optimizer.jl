
"""
Abstract type for portfolio optimization.
```julia
generate_weights(opt, initial_weights)
```
"""
abstract type AbstractPortfolioOptimizer end

function generate_weights(
    opt::AbstractPortfolioOptimizer, initial_weights::Dict{Symbol,Float64}
)
    return error(
        "generate_weights not implemented for portfolio optimizer type $(typeof(opt))"
    )
end

"""
Portfolio optimizer for fixed asset weights

Fields
------
- `data_handler::AbstractDataHandler`
"""
struct FixedWeightPortfolioOptimizer <: AbstractPortfolioOptimizer
    data_handler::AbstractDataHandler
end

function generate_weights(
    opt::FixedWeightPortfolioOptimizer, initial_weights::Dict{Symbol,Float64}
)
    return initial_weights
end

"""
Portfolio optimizer for fixed asset weights

Fields
------
- `data_handler::AbstractDataHandler`
- `scale::Float64`
"""
struct EqualWeightPortfolioOptimizer <: AbstractPortfolioOptimizer
    data_handler::AbstractDataHandler
    scale::Float64
    function EqualWeightPortfolioOptimizer(
        data_handler::AbstractDataHandler, scale::Float64=1.0
    )
        return new(data_handler, scale)
    end
end

function generate_weights(
    opt::EqualWeightPortfolioOptimizer, initial_weights::Dict{Symbol,Float64}
)
    assets = keys(initial_weights)
    n_assets = length(assets)
    equal_weight = 1.0 / n_assets
    scaled_equal_weight = opt.scale * equal_weight
    new_weights = copy(initial_weights)
    for asset in assets
        new_weights[asset] = scaled_equal_weight
    end
    return new_weights
end

"""
```julia
generate_weights(opt, initial_weights)
```

Generate portfolio weights

Parameters
----------
- `opt`
- `initial_weights::Dict{Symbol}`

Returns
-------
- `Dict{Symbol}`: new_weights
"""
generate_weights
