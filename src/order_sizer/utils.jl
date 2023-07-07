function _normalize_weights(weights::Dict, allow_negative::Bool=false, gross_leverage::Float64=1.0)
    weight_sum = 0.0
    for (asset, weight) in weights
        if !allow_negative && weight < 0.0
            error("$asset => $weight weight is below 0.")
        end
        weight_sum += allow_negative ? abs(weight) : weight
    end

    if weight_sum == 0
        return weights
    else
        ratio = allow_negative ? gross_leverage / weight_sum : 1.0 / weight_sum

        normalized_weights = copy(weights)
        for asset in keys(normalized_weights)
            normalized_weights[asset] *= ratio
        end
        return normalized_weights
    end
end


"""
Using the max amount that we are willing to pay for an equity, 
calculate the quantity that we should buy to get as close
as possible without going over.

"""
function _calculate_asset_quantity(fee_model::FeeModel, max_cost::Float64, price::Float64)
    quantity = Int(floor(max_cost / price))
    fee = calculate_fee(fee_model, quantity, price)
    while (quantity * price + fee) > max_cost
        quantity -= 1
        fee = calculate_fee(fee_model, quantity, price)
    end
    return quantity
end