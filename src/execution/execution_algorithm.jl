
"""
Execution algorithm for generating order
rebalances.
"""
abstract type ExecutionAlgorithm end

"""
Market order execution algorithm.

The execution algorithm returns the vector of orders
"""
struct MarketOrderExecutionAlgorithm <: ExecutionAlgorithm end

function execute(algo::MarketOrderExecutionAlgorithm, rebalance_orders::Vector{Order})
    return rebalance_orders
end

"""
```julia
execute(algo, ord::Vector{Order})
```

Execute algorithm to get rebalanced portfolio

Parameters
----------
- `algo`
- `ord::Vector{Order}`

Returns
-------
- `Vector{Order}`
"""
execute
