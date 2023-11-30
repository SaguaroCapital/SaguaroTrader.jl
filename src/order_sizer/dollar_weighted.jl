
"""
Create target portfolio quantities using the total equity
available to the order sizer.

Fields
------
- `broker`
- `portfolio_id::String`
- `cash_buffer_percentage::Float64=0.05`
"""
struct DollarWeightedOrderSizer <: OrderSizer
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
function (order_sizer::DollarWeightedOrderSizer)(broker, portfolio_id::String,
                                                 weights::Dict, dt::DateTime)
    portfolio_equity = total_equity(broker.portfolios[portfolio_id])
    cash_buffered_total_equity = portfolio_equity *
                                 (1.0 - order_sizer.cash_buffer_percentage)

    # no weights
    if length(weights) == 0
        return Dict{Asset,Int}()
    end

    for (asset, weight) in weights
        if weight < 0.0
            error("$asset => $weight weight is below 0.")
        end
    end

    normalized_weights = _normalize_weights(weights)
    target_portfolio = Dict{Asset,Int}()
    for (asset, weight) in normalized_weights
        dollar_weight = cash_buffered_total_equity * weight
        price = get_asset_latest_ask_price(broker.data_handler, dt, asset.symbol)
        if isnan(price)
            @warn "Unable to get price of asset $asset at $dt. Setting quantity to 0."
            asset_quantity = 0
        else
            asset_quantity = _calculate_asset_quantity(broker.fee_model, dollar_weight,
                                                       price)
        end
        target_portfolio[asset] = asset_quantity
    end
    return target_portfolio
end
