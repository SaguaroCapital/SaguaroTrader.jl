
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

function execute(algo::MarketOrderExecutionAlgorithm, rebalance_orders)
    return rebalance_orders
end

"""
```julia
execute(algo, rebalance_orders)
```

Execution algorithm to get rebalanced portfolio

Parameters
----------
- `algo`
- `rebalance_orders`

Returns
-------
- `Vector{Order}`
"""
execute
