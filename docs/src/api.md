```@meta
CurrentModule = SaguaroTrader
```

# API

```@index
```


# Asset
```@docs
Asset
Cash
Equity
Universe
DynamicUniverse
StaticUniverse
```

# Order
```@docs
Order
```

# Portfolio Optimization
```@docs
PortfolioOptimizer
FixedWeightPortfolioOptimizer
EqualWeightPortfolioOptimizer
```

# Exchange 
```@docs
Exchange
SimulatedExchange
AlwaysOpenExchange
```

# Fee Model
```@docs
FeeModel
ZeroFeeModel
PercentFeeModel
calculate_fee
```

# Data Source
```@docs
DataSource
CSVDailyBarSource
get_bid
get_ask
get_assets_historical_bids
```

# Data Handler
```@docs
DataHandler
BacktestDataHandler
get_asset_latest_bid_ask_price
get_asset_latest_mid_price
get_assets_historical_range_close_price
```

# Transaction
```@docs
Transaction
cost_without_fee
cost_with_fee
```

# Position
```@docs
Position
position_from_transaction
PositionHandler
```

# Portfolio
```@docs
PortfolioEvent
create_subscription
create_withdrawal
create_asset_transaction
Portfolio
total_market_value
total_equity
```

# Alpha Model
```@docs
AlphaModel
FixedSignalsAlphaModel
RollingSignalsAlphaModel
SingleSignalAlphaModel
```

# Slippage Model
```@docs
SlippageModel
FixedSlippageModel
PercentSlippageModel
```

# Broker
```@docs
SimulatedBroker
create_portfolio!
subscribe_funds!
withdraw_funds!
subscribe_funds_to_portfolio!
withdraw_funds_from_portfolio!
```

# Order Sizer
```@docs
OrderSizer
DollarWeightedOrderSizer
LongShortOrderSizer
```

# Portfolio Construction Model
```@docs
PortfolioConstructionModel
```

# Rebalance
```@docs
Rebalance
BuyAndHoldRebalance
DailyRebalance
MonthlyRebalance
```
