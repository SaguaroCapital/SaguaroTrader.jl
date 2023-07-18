
using Aqua
using CSV
using DataFrames
using Dates
using MarketData
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

@testset verbose = true "Code quality (Aqua.jl)" begin
    Aqua.test_all(SaguaroTrader; ambiguities=false, project_toml_formatting=false)
end
