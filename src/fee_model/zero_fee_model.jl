
"""
A FeeModel that produces no fee/fees/taxes.

total_fee = 0.0
"""
struct ZeroFeeModel end

function _calc_tax(fee_model::ZeroFeeModel, quantity::Real, price::Float64)
    return 0.0
end

function _calc_fee(fee_model::ZeroFeeModel, quantity::Real, price::Float64)
    return 0.0
end
