module SaguaroTrader

using CSV
using DataFrames
using Dates
using DataStructures
using Random
using UUIDs

include("utils.jl")
include("asset/asset.jl")
include("order/order.jl")
include("fee_model/fee_model.jl")
include("exchange/exchange.jl")
include("data/data.jl")
include("data/impute.jl")
include("portfolio/portfolio.jl")
include("portfolio_optimizer/portfolio_optimizer.jl")
include("slippage_model/slippage_model.jl")

include("alpha_model/alpha_model.jl")
include("risk_model/risk_model.jl")
include("rebalance/rebalance.jl")

include("broker/broker.jl")
include("order_sizer/order_sizer.jl")
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
      Asset,
      Cash,
      Equity,
      Universe,
      DynamicUniverse,
      StaticUniverse,

# order
      Order,

# exchange
      Exchange,
      SimulatedExchange,
      AlwaysOpenExchange,

# fee model
      FeeModel,
      ZeroFeeModel,
      PercentFeeModel,
      calculate_fee,

# data source
      DataSource,
      CSVDailyBarSource,
      get_bid,
      get_ask,
      get_assets_historical_bids,

# data handler
      DataHandler,
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
      AlphaModel,
      FixedSignalsAlphaModel,
      RollingSignalsAlphaModel,
      SingleSignalAlphaModel,

# slippage model
      SlippageModel,
      ZeroSlippageModel,
      FixedSlippageModel,
      PercentSlippageModel,
      VolumeSharesSlippageModel,

# portfolio optimizer
      PortfolioOptimizer,
      FixedWeightPortfolioOptimizer,
      EqualWeightPortfolioOptimizer,

# broker
      SimulatedBroker,
      create_portfolio!,
      subscribe_funds!,
      withdraw_funds!,
      subscribe_funds_to_portfolio!,
      withdraw_funds_from_portfolio!,

# order sizer
      OrderSizer,
      DollarWeightedOrderSizer,
      LongShortOrderSizer,

# pcm
      PortfolioConstructionModel,

# rebalance
      Rebalance,
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
