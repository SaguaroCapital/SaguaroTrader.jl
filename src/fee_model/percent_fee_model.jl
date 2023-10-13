
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
struct PercentFeeModel
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
