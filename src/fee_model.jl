
abstract type AbstractFeeModel end
"""
Abstract type to handle the calculation of 
brokerage fee, fees and taxes.
"""
AbstractFeeModel

function _calc_tax(fee_model::AbstractFeeModel, quantity::Real, price::Float64)
    return error("_calc_tax not implemented for fee model type $(typeof(fee_model))")
end

function _calc_fee(fee_model::AbstractFeeModel, quantity::Real, price::Float64)
    return error("_calc_fee not implemented for fee model type $(typeof(fee_model))")
end

"""
```julia
calculate_fee(fee_model, quantity::Real, price::Float64)
```

Calculate the fee for an order

Parameters
----------
- `fee_model`
- `quantity::Real`
- `price::Float64`

Returns
-------
- `Float64`: The total fee for the order (tax + fee)
"""
function calculate_fee(fee_model::AbstractFeeModel, quantity::Real, price::Float64)
    tax = _calc_tax(fee_model, quantity, price)
    fee = _calc_fee(fee_model, quantity, price)
    return tax + fee
end

############################################################
# zero fee model
############################################################
"""
A FeeModel that produces no fee/fees/taxes.

total_fee = 0.0
"""
struct ZeroFeeModel <: AbstractFeeModel end

function _calc_tax(fee_model::ZeroFeeModel, quantity::Real, price::Float64)
    return 0.0
end

function _calc_fee(fee_model::ZeroFeeModel, quantity::Real, price::Float64)
    return 0.0
end

############################################################
# percent fee model
############################################################
"""
A Fee model that calculates tax and fee
fees using a percentage of the total order price (considaration). 

fee_fee = (order.price * order.quantity) * fee_model.fee_pct
tax_fee = (order.price * order.quantity) * fee_model.tax_pct
total_fee = tax_fee + fee_fee

Fields
------
- `fee_pct::Float64` = 0.0
- `tax_pct::Float64` = 0.0
"""
struct PercentFeeModel <: AbstractFeeModel
    fee_pct::Float64
    tax_pct::Float64
    function PercentFeeModel(; fee_pct::Float64=0.0, tax_pct::Float64=0.0)
        return new(fee_pct, tax_pct)
    end
end

function _calc_tax(fee_model::PercentFeeModel, quantity::Real, price::Float64)
    consideration = price * quantity
    return consideration * (fee_model.tax_pct / 100)
end

function _calc_fee(fee_model::PercentFeeModel, quantity::Real, price::Float64)
    consideration = price * quantity
    return consideration * (fee_model.fee_pct / 100)
end
