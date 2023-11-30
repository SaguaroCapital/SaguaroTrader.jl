
"""
This is an `Order` for an asset.

Fields
------
- `created_dt::DateTime` - datetime that the order was placed
- `quantity::Real` - order quantity 
- `asset::Asset` - order asset
- `fee::Float64` - order fee
- `order_id::String` - unique order id
- `direction::Int`  1=>buy, -1=>sell
- `direction::Float64` - Asset volume (for predicting slippage)
"""
struct Order
    created_dt::DateTime
    quantity::Real
    asset::Asset
    fee::Float64
    order_id::String
    direction::Int
    volume::Float64
    # type::Symbol #TODO: add order types (market, limit, ...)
    function Order(order_dt::DateTime,
                   quantity::Real,
                   asset::Asset;
                   fee::Float64=0.0,
                   order_id::String=generate_id())
        direction = sign(quantity)
        return new(order_dt, quantity, asset, fee, order_id, direction)
    end
end

"""
```julia
equal_orders(ord1, ord2)
```

Assert if two orders are the same (other than the id)

Parameters
----------
- `ord1`
- `ord2`

Returns
-------
- `Bool`: true if two orders are the same (other than the id)
"""
function equal_orders(ord1, ord2)
    if ord1.created_dt != ord2.created_dt
        return false
    elseif ord1.quantity != ord2.quantity
        return false
    elseif ord1.asset != ord2.asset
        return false
    elseif ord1.fee != ord2.fee
        return false
    else
        return true
    end
end
