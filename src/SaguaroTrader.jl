module SaguaroTrader

using CSV: CSV
using DataFrames:
    DataFrames, DataFrame, dropmissing!, order, outerjoin, select, select!, transform
using DataStructures: DataStructures, Queue, dequeue!, enqueue!
using Dates: Dates, Date, DateTime, Day, Hour, Minute, Month, Time, Week, Year, dayofweek
using PrecompileTools: PrecompileTools, @compile_workload, @setup_workload
using Random: Random
using UUIDs: UUIDs

include("utils.jl")
include("asset.jl")
include("order.jl")
include("fee_model.jl")
include("exchange.jl")
include("data/data.jl")
include("portfolio/portfolio.jl")
include("portfolio_optimizer/portfolio_optimizer.jl")
include("slippage_model/slippage_model.jl")

include("alpha_model.jl")
include("risk_model.jl")
include("rebalance.jl")

include("broker.jl")
include("order_sizer.jl")
include("execution/execution.jl")
include("portfolio_construction_model/portfolio_construction_model.jl")
include("backtest_trading_session/backtest_trading_session.jl")

include("ext.jl")

include("precompile.jl")

if !isdefined(Base, :get_extension)
    include("../ext/MarketDataExt.jl")
end

export

    # asset
    AbstractAsset,
    Cash,
    Equity,
    Universe,
    DynamicUniverse,
    StaticUniverse,

    # order
    Order,

    # exchange
    AbstractExchange,
    SimulatedExchange,
    AlwaysOpenExchange,

    # fee model
    AbstractFeeModel,
    ZeroFeeModel,
    PercentFeeModel,
    calculate_fee,

    # data source
    AbstractDataSource,
    CSVDailyBarSource,
    get_bid,
    get_ask,
    get_assets_historical_bids,

    # data handler
    AbstractDataHandler,
    BacktestDataHandler,
    get_asset_latest_bid_ask_price,
    get_asset_latest_mid_price,
    get_assets_historical_range_close_price,

    # portfolio
    Transaction,
    cost_without_fee,
    cost_with_fee,
    Position,
    position_from_transaction,
    PositionHandler,
    PortfolioEvent,
    create_subscription,
    create_withdrawal,
    create_asset_transaction,
    Portfolio,
    total_market_value,
    total_equity,

    # alpha model
    AbstractAlphaModel,
    FixedSignalsAlphaModel,
    RollingSignalsAlphaModel,
    SingleSignalAlphaModel,

    # slippage model
    AbstractSlippageModel,
    ZeroSlippageModel,
    FixedSlippageModel,
    PercentSlippageModel,
    VolumeSharesSlippageModel,

    # portfolio optimizer
    AbstractPortfolioOptimizer,
    FixedWeightPortfolioOptimizer,
    EqualWeightPortfolioOptimizer,

    # broker
    AbstractBroker,
    SimulatedBroker,
    create_portfolio!,
    subscribe_funds!,
    withdraw_funds!,
    subscribe_funds_to_portfolio!,
    withdraw_funds_from_portfolio!,

    # order sizer
    AbstractOrderSizer,
    DollarWeightedOrderSizer,
    LongShortOrderSizer,

    # pcm
    PortfolioConstructionModel,

    # rebalance
    AbstractRebalance,
    BuyAndHoldRebalance,
    DailyRebalance,
    WeeklyRebalance,
    MonthlyRebalance,

    # Trading
    BacktestTradingSession,
    run!,

    #ext
    download_market_data

end
