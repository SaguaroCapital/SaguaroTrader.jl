
include("execution_algorithm.jl")

"""
Struct to hold data needed to execute
a vector of orders through the `Broker`.

Fields
------
- `broker::Broker`
- `portfolio_id::String`
- `execution_algorithm::ExecutionAlgorithm`
- `data_handler::DataHandler`
- `submit_orders::Bool`
"""
struct ExecutionHandler
    broker::Broker
    portfolio_id::String
    execution_algorithm::ExecutionAlgorithm
    submit_orders::Bool
    function ExecutionHandler(broker::Broker,
                              portfolio_id::String;
                              execution_algorithm::ExecutionAlgorithm=MarketOrderExecutionAlgorithm(),
                              submit_orders::Bool=false)
        return new(broker, portfolio_id, execution_algorithm, submit_orders)
    end
end

function execute(exec_handler::ExecutionHandler, rebalance_orders)
    return execute(exec_handler.execution_algorithm, rebalance_orders)
end

function (exec_handler::ExecutionHandler)(rebalance_orders)
    if exec_handler.submit_orders
        final_orders = execute(exec_handler, rebalance_orders)
        sell_orders = [order for order in final_orders if order.direction < 0]
        buy_orders = [order for order in final_orders if order.direction > 0]
        for order in sell_orders
            submit_order!(exec_handler.broker, exec_handler.portfolio_id, order)
        end
        for order in buy_orders
            submit_order!(exec_handler.broker, exec_handler.portfolio_id, order)
        end
    end
end
