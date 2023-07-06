
function _normalize_weights(weights::Dict)
    weight_sum = 0.0
    for (asset, weight) in weights
        if weight < 0.0
            error("$asset => $weight weight is below 0.")
        end
        weight_sum += weight
    end

    if weight_sum == 0
        return weights
    else
        normalized_weights = copy(weights)
        for asset in keys(normalized_weights)
            normalized_weights[asset] /= weight_sum
        end
        return normalized_weights
    end
end

function _normalize_weights_long_short(weights::Dict, gross_leverage::Float64=1.0)
    weight_sum = 0.0
    for (asset, weight) in weights
        weight_sum += abs(weight)
    end

    if weight_sum == 0
        return weights
    else
        gross_ratio = gross_leverage / weight_sum

        normalized_weights = copy(weights)
        for asset in keys(normalized_weights)
            normalized_weights[asset] *= gross_ratio
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