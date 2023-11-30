
"""
Metadata about a transaction of an asset

Fields
------
- `asset::Symbol`
- `quantity::Float64`
- `dt::DateTime`
- `price::Float64`
- `fee::Float64`
- `order_id::String`
"""
struct Transaction
    asset::Asset
    quantity::Float64
    dt::DateTime
    price::Float64
    fee::Float64
    order_id::String
    """
    ```julia
    Transaction(
        asset::Asset,
        quantity::Float64,
        dt::DateTime,
        price::Float64,
        fee::Float64,
        order_id::String = generate_id(),
    )
    ```
    """
    function Transaction(asset::Asset,
                         quantity::Real,
                         dt::DateTime,
                         price::Float64,
                         fee::Float64,
                         order_id::String=generate_id())
        return new(asset, float(quantity), dt, price, fee, order_id)
    end
end

direction(txn::Transaction) = Int(sign(txn.quantity::Float64)::Float64)::Int

"""
```julia
cost_without_fee(txn::Transaction)
```

Cost of a transaction without fee

Parameters
----------
- `txn::Transaction`

Returns
-------
- `Float64`
"""
function cost_without_fee(txn::Transaction)
    return txn.quantity::Float64 * txn.price::Float64
end

"""
```julia
cost_with_fee(txn::Transaction)
```

Cost of a transaction with fee

Parameters
----------
- `txn::Transaction`

Returns
-------
- `Float64`
"""
function cost_with_fee(txn::Transaction)
    return txn.quantity * txn.price + txn.fee
end
