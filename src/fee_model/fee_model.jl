
"""
Abstract type to handle the calculation of 
brokerage fee, fees and taxes.
"""
abstract type FeeModel end

include("zero_fee_model.jl")
include("percent_fee_model.jl")

"""
```julia
calculate_fee(fee_model::FeeModel, quantity::Real, price::Float64)
```

Calculate the fee for an order

Parameters
----------
- `fee_model::FeeModel`
- `quantity::Real`
- `price::Float64`

Returns
-------
- `Float64`: The total fee for the order (tax + fee)
"""
function calculate_fee(fee_model::FeeModel, quantity::Real, price::Float64)
    tax = _calc_tax(fee_model, quantity, price)
    fee = _calc_fee(fee_model, quantity, price)
    return tax + fee
end
