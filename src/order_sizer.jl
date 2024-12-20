
"""
Create target asset quantities for portfolios
"""
abstract type AbstractOrderSizer end

function (order_sizer::AbstractOrderSizer)(weights::Dict)
    return error("No order size calculation implemented for $(typeof(order_sizer))")
end

function _normalize_weights(weights::Dict)
    weight_sum = 0.0
    for (asset, weight) in weights
        weight_sum += abs(weight)
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

"""
Using the max amount that we are willing to pay for an equity, 
calculate the quantity that we should buy to get as close
as possible without going over.

"""
function _calculate_asset_quantity(fee_model, max_cost::Float64, price::Float64)
    quantity = Int(floor(max_cost / price))
    fee = calculate_fee(fee_model, quantity, price)
    while (quantity * price + fee) > max_cost
        quantity -= 1
        fee = calculate_fee(fee_model, quantity, price)
    end
    return quantity
end

############################################################
# dollar weighted
############################################################

"""
Create target portfolio quantities using the total equity
available to the order sizer.

Fields
------
- `broker`
- `portfolio_id::String`
- `cash_buffer_percentage::Float64=0.05`
"""
struct DollarWeightedOrderSizer <: AbstractOrderSizer
    cash_buffer_percentage::Float64
    function DollarWeightedOrderSizer(cash_buffer_percentage::Float64=0.01)
        @assert (cash_buffer_percentage >= 0.0) & (cash_buffer_percentage <= 1.0)
        return new(cash_buffer_percentage)
    end
end

"""
Creates a dollar-weighted cash-buffered target portfolio from the
provided target weights at a particular timestamp.

#TODO: Work with short positions
"""
function (order_sizer::DollarWeightedOrderSizer)(
    broker, portfolio_id::String, weights::Dict, dt::DateTime
)
    portfolio_equity = total_equity(broker.portfolios[portfolio_id])
    cash_buffered_total_equity =
        portfolio_equity * (1.0 - order_sizer.cash_buffer_percentage)

    # no weights
    if length(weights) == 0
        return Dict{AbstractAsset,Int}()
    end

    for (asset, weight) in weights
        if weight < 0.0
            error("$asset => $weight weight is below 0.")
        end
    end

    normalized_weights = _normalize_weights(weights)
    target_portfolio = Dict{AbstractAsset,Int}()
    for (asset, weight) in normalized_weights
        dollar_weight = cash_buffered_total_equity * weight
        price = get_asset_latest_ask_price(broker.data_handler, dt, asset.symbol)
        if isnan(price)
            @warn "Unable to get price of asset $asset at $dt. Setting quantity to 0."
            asset_quantity = 0
        else
            asset_quantity = _calculate_asset_quantity(
                broker.fee_model, dollar_weight, price
            )
        end
        target_portfolio[asset] = asset_quantity
    end
    return target_portfolio
end

############################################################
# long short
############################################################
"""
Create target portfolio quantities using the total equity
available to the order sizer.

Fields
------
- `broker`
- `portfolio_id::String`
- `gross_leverage::Float64=1.0`
"""
struct LongShortOrderSizer <: AbstractOrderSizer
    gross_leverage::Float64
    function LongShortOrderSizer(gross_leverage::Float64=1.0)
        @assert (gross_leverage > 0.0) "gross_leverage must be positive"
        return new(gross_leverage)
    end
end

function (order_sizer::LongShortOrderSizer)(
    broker, portfolio_id::String, weights::Dict, dt::DateTime
)
    portfolio_equity = total_equity(broker.portfolios[portfolio_id])

    # no weights
    if length(weights) == 0
        return Dict{AbstractAsset,Int}()
    end

    normalized_weights = _normalize_weights(weights)
    target_portfolio = Dict{AbstractAsset,Int}()
    for (asset, weight) in normalized_weights
        dollar_weight = portfolio_equity * order_sizer.gross_leverage * weight
        price = get_asset_latest_ask_price(broker.data_handler, dt, asset.symbol)
        if isnan(price)
            @warn "Unable to get price of asset $asset at $dt. Setting quantity to 0."
            asset_quantity = 0
        else
            asset_quantity = _calculate_asset_quantity(
                broker.fee_model, dollar_weight, price
            )
        end
        target_portfolio[asset] = asset_quantity
    end
    return target_portfolio
end
