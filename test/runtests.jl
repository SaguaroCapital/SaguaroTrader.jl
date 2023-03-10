
using CSV
using DataFrames
using Dates
using SaguaroTrader
using Test

tests = [
    "asset",
    "order",
    "rebalance",
    "exchange",
    "fee_model",
    "data",
    "portfolio",
    "alpha_model",
    "slippage_model",
    "portfolio_optimizer",
    "broker",
    "order_sizer",
    "execution",
    "portfolio_construction_model",
    "backtest",
]

println("Running tests:")
for t in tests
    fp = "$(t).jl"
    println("* $fp ...")
    include(fp)
end
