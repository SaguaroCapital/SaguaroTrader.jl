"""
Create target portfolio quantities using the total equity
available to the order sizer.

Fields
------
- `broker::Broker`
- `portfolio_id::String`
- `gross_leverage::Float64=1.0`
"""
struct LongShortOrderSizer <: OrderSizer
    gross_leverage::Float64
    function LongShortOrderSizer(gross_leverage::Float64=1.0)
        @assert (gross_leverage > 0.0) "gross_leverage must be positive"
        return new(gross_leverage)
    end
end

function (order_sizer::LongShortOrderSizer)(
    broker::Broker, portfolio_id::String, weights::Dict, dt::DateTime
)
    portfolio_equity = total_equity(broker.portfolios[portfolio_id])

    # no weights
    if length(weights) == 0
        return Dict{Asset,Int}()
    end

    normalized_weights = _normalize_weights(weights, true, order_sizer.gross_leverage)
    target_portfolio = Dict{Asset,Int}()
    for (asset, weight) in normalized_weights
        dollar_weight = portfolio_equity * weight
        price = get_asset_latest_ask_price(broker.data_handler, dt, asset.symbol)
        asset_quantity = _calculate_asset_quantity(broker.fee_model, dollar_weight, price)
        target_portfolio[asset] = asset_quantity
    end
    return target_portfolio
end
