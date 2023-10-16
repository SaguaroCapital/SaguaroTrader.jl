
"""

"""
struct QuantTradingSystem
    universe
    broker
    portfolio_id::String
    alpha_model
    order_sizer
    # risk_model #TODO: Implement
    long_only::Bool
    submit_orders::Bool
    function QuantTradingSystem(
        universe,
        broker,
        portfolio_id::String,
        alpha_model;
        long_only::Bool=false,
        cash_buffer_percentage::Float64=0.05,
        gross_leverage::Float64=1.0,
        submit_orders::Bool=false,
    )
        if long_only
            order_sizer = DollarWeightedOrderSizer(cash_buffer_percentage)
        else
            order_sizer = LongShortOrderSizer(gross_leverage)
        end

        return new(
            universe,
            broker,
            portfolio_id,
            data_handler,
            alpha_model,
            order_sizer,
            long_only,
            submit_orders,
        )
    end
end
