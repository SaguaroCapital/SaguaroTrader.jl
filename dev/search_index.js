var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API","title":"API","text":"CurrentModule = SaguaroTrader","category":"page"},{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/#Asset","page":"API","title":"Asset","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Asset\nCash\nEquity\nUniverse\nDynamicUniverse\nStaticUniverse","category":"page"},{"location":"api/#SaguaroTrader.Asset","page":"API","title":"SaguaroTrader.Asset","text":"Metadata about an Asset\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.Cash","page":"API","title":"SaguaroTrader.Cash","text":"Equity asset type.\n\nFields\n\ncurrency::String - currency of the cash\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.Equity","page":"API","title":"SaguaroTrader.Equity","text":"Equity asset type.\n\nFields\n\nsymbol::Symbol - asset symbol\nname::String - name of the asset\ntax_exempt::Bool=false - asset tax exemption status\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.Universe","page":"API","title":"SaguaroTrader.Universe","text":"Abstract type for asset universes\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.DynamicUniverse","page":"API","title":"SaguaroTrader.DynamicUniverse","text":"Dynamic asset universe. Each asset has a start date\n\nParameters\n\nasset_dates::Vector{Dict{Symbol,DateTime}}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.StaticUniverse","page":"API","title":"SaguaroTrader.StaticUniverse","text":"Satatic asset universe\n\nParameters\n\nasset_dates::Vector{Dict{Symbol,DateTime}}\n\n\n\n\n\n","category":"type"},{"location":"api/#Order","page":"API","title":"Order","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Order","category":"page"},{"location":"api/#SaguaroTrader.Order","page":"API","title":"SaguaroTrader.Order","text":"This is an Order for an asset.\n\nFields\n\ncreated_dt::DateTime - datetime that the order was placed\nquantity::Real - order quantity \nasset::Asset - order asset\nfee::Float64 - order fee\norder_id::String - unique order id\ndirection::Int  1=>buy, -1=>sell\n\n\n\n\n\n","category":"type"},{"location":"api/#Portfolio-Optimization","page":"API","title":"Portfolio Optimization","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"PortfolioOptimizer\nFixedWeightPortfolioOptimizer\nEqualWeightPortfolioOptimizer","category":"page"},{"location":"api/#SaguaroTrader.PortfolioOptimizer","page":"API","title":"SaguaroTrader.PortfolioOptimizer","text":"Abstract type for portfolio optimization.\n\ngenerate_weights(opt::PortfolioOptimizer, initial_weights)\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.FixedWeightPortfolioOptimizer","page":"API","title":"SaguaroTrader.FixedWeightPortfolioOptimizer","text":"Portfolio optimizer for fixed asset weights\n\nFields\n\ndata_handler::DataHandler\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.EqualWeightPortfolioOptimizer","page":"API","title":"SaguaroTrader.EqualWeightPortfolioOptimizer","text":"Portfolio optimizer for fixed asset weights\n\nFields\n\ndata_handler::DataHandler\nscale::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#Exchange","page":"API","title":"Exchange","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Exchange\nSimulatedExchange\nAlwaysOpenExchange","category":"page"},{"location":"api/#SaguaroTrader.Exchange","page":"API","title":"SaguaroTrader.Exchange","text":"Abstract type for trading exchange\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.SimulatedExchange","page":"API","title":"SaguaroTrader.SimulatedExchange","text":"Simulate live trading\n\nFields\n\nstart_dt::DateTime\nopen_time::Time=Time(14,30)\nclose_time::Time=Time(21,00)\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.AlwaysOpenExchange","page":"API","title":"SaguaroTrader.AlwaysOpenExchange","text":"Simulate an exchange that never closes\n\nFields\n\nstart_dt::DateTime\n\n\n\n\n\n","category":"type"},{"location":"api/#Fee-Model","page":"API","title":"Fee Model","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"FeeModel\nZeroFeeModel\nPercentFeeModel\ncalculate_fee","category":"page"},{"location":"api/#SaguaroTrader.FeeModel","page":"API","title":"SaguaroTrader.FeeModel","text":"Abstract type to handle the calculation of  brokerage fee, fees and taxes.\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.ZeroFeeModel","page":"API","title":"SaguaroTrader.ZeroFeeModel","text":"A FeeModel that produces no fee/fees/taxes.\n\ntotal_fee = 0.0\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.PercentFeeModel","page":"API","title":"SaguaroTrader.PercentFeeModel","text":"A Fee model that calculates tax and fee fees using a percentage of the total order price (considaration). \n\nfeefee = (order.price * order.quantity) * feemodel.feepct taxfee = (order.price * order.quantity) * feemodel.taxpct totalfee = taxfee + fee_fee\n\nFields\n\nfee_pct::Float64 = 0.0\ntax_pct::Float64 = 0.0\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.calculate_fee","page":"API","title":"SaguaroTrader.calculate_fee","text":"calculate_fee(fee_model::FeeModel, quantity::Real, price::Float64)\n\nCalculate the fee for an order\n\nParameters\n\nfee_model::FeeModel\nquantity::Real\nprice::Float64\n\nReturns\n\nFloat64: The total fee for the order (tax + fee)\n\n\n\n\n\n","category":"function"},{"location":"api/#Data-Source","page":"API","title":"Data Source","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"DataSource\nCSVDailyBarSource\nget_bid\nget_ask\nget_assets_historical_bids","category":"page"},{"location":"api/#SaguaroTrader.DataSource","page":"API","title":"SaguaroTrader.DataSource","text":"Abstract type for a data source. \n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.CSVDailyBarSource","page":"API","title":"SaguaroTrader.CSVDailyBarSource","text":"Encapsulates loading, preparation and querying of CSV files of daily 'bar' OHLCV data. The CSV files are converted into a intraday timestamped Pandas DataFrame with opening and closing prices.\n\nOptionally utilises adjusted closing prices (if available) to adjust both the close and open.\n\nFields\n\ncsv_dir::String   The full path to the directory where the CSV is located.\nasset_type::String   The asset type that the price/volume data is for.\nadjust_prices::String   Whether to utilise corporate-action adjusted prices for both   the open and closing prices. Defaults to True.\ncsv_symbols::Vector   An optional list of CSV symbols to restrict the data source to.   The alternative is to convert all CSVs found within the   provided directory.\ndict_asset_dfs::Dict{Symbol, DataFrame}   Automatically generated dictionary of asset symbols, and    pricing dataframes\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.get_bid","page":"API","title":"SaguaroTrader.get_bid","text":"get_bid(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)\n\nGet the bid price for an asset at a certain time.\n\nParameters\n\nds::CSVDailyBarSource\ndt::DateTime\nasset::Symbol\n\nReturns\n\nFloat64: bid for an asset at the given datetime\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.get_ask","page":"API","title":"SaguaroTrader.get_ask","text":"get_ask(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)\n\nGet the ask price for an asset at a certain time.\n\nParameters\n\nds::CSVDailyBarSource\ndt::DateTime\nasset::Symbol\n\nReturns\n\nFloat64: ask for an asset at the given datetime\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.get_assets_historical_bids","page":"API","title":"SaguaroTrader.get_assets_historical_bids","text":"get_ask(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)\n\nObtain a multi-asset historical range of closing prices as a DataFrame\n\nParameters\n\nds::CSVDailyBarSource\nstart_dt::DateTime\nend_dt::DateTime\nasset::Symbol\n\nReturns\n\nDataFrame: Dataframe with the bid timestamps, asset symbols, and\n\n\n\n\n\n","category":"function"},{"location":"api/#Data-Handler","page":"API","title":"Data Handler","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"DataHandler\nBacktestDataHandler\nget_asset_latest_bid_ask_price\nget_asset_latest_mid_price\nget_assets_historical_range_close_price","category":"page"},{"location":"api/#SaguaroTrader.DataHandler","page":"API","title":"SaguaroTrader.DataHandler","text":"Abstract type for a data handler.\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.BacktestDataHandler","page":"API","title":"SaguaroTrader.BacktestDataHandler","text":"Data Handler for backtesting Fields –––\n\ndata_sources::Vector{DataSource}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.get_asset_latest_bid_ask_price","page":"API","title":"SaguaroTrader.get_asset_latest_bid_ask_price","text":"get_asset_latest_bid_ask_price(dh::DataHandler, dt::DateTime, asset::Symbol)\n\nGet the bid, ask price for an asset at a certain time.\n\nParameters\n\ndh::DataHandler\ndt::DateTime\nasset::Symbol\n\nReturns\n\nTuple{Float64, Float64}: (bid, ask) for an asset at the given datetime\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.get_asset_latest_mid_price","page":"API","title":"SaguaroTrader.get_asset_latest_mid_price","text":"get_asset_latest_mid_price(dh::DataHandler, dt::DateTime, asset::Symbol)\n\nGet the average of bid/ask price for an asset at a certain time.\n\nParameters\n\ndh::DataHandler\ndt::DateTime\nasset::Symbol\n\nReturns\n\nFloat64: mid point between bid/ask for an asset at the given datetime\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.get_assets_historical_range_close_price","page":"API","title":"SaguaroTrader.get_assets_historical_range_close_price","text":"get_assets_historical_range_close_price(\n    dh::DataHandler,\n    start_dt::DateTime,\n    end_dt::DateTime,\n    assets::Vector{Symbol},\n)  \n\nAll closing prices for the given assets in the given timerange\n\nParameters\n\ndh::DataHandler\nstart_dt::DateTime\nend_dt::DateTime\nasset::Vector{Symbol}\n\nReturns\n\nDataFrame: dataframe of close prices for the assets\n\n\n\n\n\n","category":"function"},{"location":"api/#Transaction","page":"API","title":"Transaction","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Transaction\ncost_without_fee\ncost_with_fee","category":"page"},{"location":"api/#SaguaroTrader.Transaction","page":"API","title":"SaguaroTrader.Transaction","text":"Metadata about a transaction of an asset\n\nFields\n\nasset::Symbol\nquantity::Float64\ndt::DateTime\nprice::Float64\nfee::Float64\norder_id::String\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.cost_without_fee","page":"API","title":"SaguaroTrader.cost_without_fee","text":"cost_without_fee(txn::Transaction)\n\nCost of a transaction without fee\n\nParameters\n\ntxn::Transaction\n\nReturns\n\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.cost_with_fee","page":"API","title":"SaguaroTrader.cost_with_fee","text":"cost_with_fee(txn::Transaction)\n\nCost of a transaction with fee\n\nParameters\n\ntxn::Transaction\n\nReturns\n\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"api/#Position","page":"API","title":"Position","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Position\nposition_from_transaction\nPositionHandler","category":"page"},{"location":"api/#SaguaroTrader.Position","page":"API","title":"SaguaroTrader.Position","text":"Handles the accounting of a position in an asset.\n\nFields\n\nasset::Symbol\ncurrent_price::Float64\ncurrent_dt::DateTime\nbuy_quantity::Float64\nsell_quantity::Float64\nnet_quantity::Float64\navg_bought::Float64\navg_sold::Float64\nbuy_fee::Float64\nsell_fee::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.position_from_transaction","page":"API","title":"SaguaroTrader.position_from_transaction","text":"position_from_transaction(txn::Transaction)::Position\n\nCreate a position using a transaction\n\nParameters\n\ntxn::Transaction\n\nReturns\n\nPosition\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.PositionHandler","page":"API","title":"SaguaroTrader.PositionHandler","text":"Store all open positions\n\n\n\n\n\n","category":"type"},{"location":"api/#Portfolio","page":"API","title":"Portfolio","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"PortfolioEvent\ncreate_subscription\ncreate_withdrawal\ncreate_asset_transaction\nPortfolio\ntotal_market_value\ntotal_equity","category":"page"},{"location":"api/#SaguaroTrader.PortfolioEvent","page":"API","title":"SaguaroTrader.PortfolioEvent","text":"Snapshot of the portfolio at a given time. \n\nFields\n\ndt::DateTime \ntype::String\ndebit::Float64\ncredit::Float64\nbalance::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.create_subscription","page":"API","title":"SaguaroTrader.create_subscription","text":"create_subscription(dt::DateTime, credit::Float64, balance::Float64)\n\nCreate a subscription portolio event\n\nParameters\n\ndt::DateTime\ncredit::Float64\nbalance::Float64\n\nReturns\n\nPortfolioEvent\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.create_withdrawal","page":"API","title":"SaguaroTrader.create_withdrawal","text":"create_withdrawal(dt::DateTime, credit::Float64, balance::Float64)\n\nCreate a withdrawal portolio event\n\nParameters\n\ndt::DateTime\ncredit::Float64\nbalance::Float64\n\nReturns\n\nPortfolioEvent\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.create_asset_transaction","page":"API","title":"SaguaroTrader.create_asset_transaction","text":"create_asset_transaction(\n    dt::DateTime,\n    txn_total_cost::Float64,\n    balance::Float64,\n    direction::Int,\n)\n\nCreate an asset buy/sell portfolio event\n\nParameters\n\ndt::DateTime\ntxn_total_cost::Float64\nbalance::Float64\ndirection::Int\n\nReturns\n\nPortfolioEvent\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.Portfolio","page":"API","title":"SaguaroTrader.Portfolio","text":"Portfolio\n\nFields\n\ncurrent_dt::DateTime\ncash::Float64\ncurrency::String\npos_handler::PositionHandler\nportfolio_id::String\nname::String\nhistory::Vector{PortfolioEvent}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.total_market_value","page":"API","title":"SaguaroTrader.total_market_value","text":"total_market_value(pos_handler::PositionHandler)\n\nTotal market value of all open positions\n\nParameters\n\npos_handler::PositionHandler\n\nReturns\n\nFloat64\n\n\n\n\n\ntotal_market_value(port::Portfolio)\n\nTotal market value of the portfolio excluding cash.\n\nParameters\n\nord1::Order\nord2::Order\n\nReturns\n\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.total_equity","page":"API","title":"SaguaroTrader.total_equity","text":"total_equity(port::Portfolio)\n\nTotal market value of the portfolio including cash.\n\nParameters\n\nord1::Order\nord2::Order\n\nReturns\n\nFloat64\n\n\n\n\n\n","category":"function"},{"location":"api/#Alpha-Model","page":"API","title":"Alpha Model","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"AlphaModel\nFixedSignalsAlphaModel\nRollingSignalsAlphaModel\nSingleSignalAlphaModel","category":"page"},{"location":"api/#SaguaroTrader.AlphaModel","page":"API","title":"SaguaroTrader.AlphaModel","text":"Abstract type for alpha models\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.FixedSignalsAlphaModel","page":"API","title":"SaguaroTrader.FixedSignalsAlphaModel","text":"A simple AlphaModel that provides a single scalar forecast value for each Asset in the Universe.\n\nFields\n\nsignal_weights::Dict{Symbol,Float64}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.RollingSignalsAlphaModel","page":"API","title":"SaguaroTrader.RollingSignalsAlphaModel","text":"Signals that change through time. Produces the most recent signal at a given time\n\nFields\n\ndict_signal_weights::Dict{DateTime, Dict{Asset,Float64}}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.SingleSignalAlphaModel","page":"API","title":"SaguaroTrader.SingleSignalAlphaModel","text":"Fixed signal for all assets in the universe\n\nFields\n\nuniverse::Universe\nsignal::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#Slippage-Model","page":"API","title":"Slippage Model","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"SlippageModel\nFixedSlippageModel\nPercentSlippageModel","category":"page"},{"location":"api/#SaguaroTrader.SlippageModel","page":"API","title":"SaguaroTrader.SlippageModel","text":"abstract type for slippage models\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.FixedSlippageModel","page":"API","title":"SaguaroTrader.FixedSlippageModel","text":"Fixed spread for all assets\n\nBuy orders will execute at ask + spread / 2 Sell orders will execute at bid - spread / 2\n\nFields\n\nspread::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.PercentSlippageModel","page":"API","title":"SaguaroTrader.PercentSlippageModel","text":"Spread is a percent of the asset price\n\nBuy orders will execute at ask * (1 + (slippage_pct/100)) Sell orders will execute at bid * (1 - (slippage_pct/100))\n\nFields\n\nslippage_pct::Float64\n\n\n\n\n\n","category":"type"},{"location":"api/#Broker","page":"API","title":"Broker","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"SimulatedBroker\ncreate_portfolio!\nsubscribe_funds!\nwithdraw_funds!\nsubscribe_funds_to_portfolio!\nwithdraw_funds_from_portfolio!","category":"page"},{"location":"api/#SaguaroTrader.SimulatedBroker","page":"API","title":"SaguaroTrader.SimulatedBroker","text":"Simlated broker for transacting assets\n\nFields\n\nstart_dt::DateTime\ncurrent_dt::DateTime\nexchange::Exchange\ndata_handler::DataHandler\naccount_id::String\nbase_currency::String\ninitial_cash::Float64\nfee_model::FeeModel\ncash_balances::Dict{String,Float64}\nportfolios::Dict{String,Portfolio}\nopen_orders::Dict{String,Queue{Order}}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.create_portfolio!","page":"API","title":"SaguaroTrader.create_portfolio!","text":"function create_portfolio!(\n    broker::Broker,\n    initial_cash::Real;\n    name::String = \"\",\n    portfolio_id::String = string(UUIDs.uuid1()),\n)\n\nfunction create_portfolio!(\n    broker::Broker;\n    name::String = \"\",\n    portfolio_id::String = string(UUIDs.uuid1()),\n)\n\nCreate a portolio using the broker's cash balance to fund the initial capital.\n\nParameters\n\nbroker::Broker\ninitial_cash::Real\nname::String = \"\"\nportfolio_id::String = string(UUIDs.uuid1())\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.subscribe_funds!","page":"API","title":"SaguaroTrader.subscribe_funds!","text":"subscribe_funds!(broker::Broker, amount::Real)\n\nsubscribe_funds!(broker::Broker, amount::Real, currency::String)\n\nAdd funds to broker\n\nParameters\n\nbroker::Broker\namount::Real\ncurrency::String\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.withdraw_funds!","page":"API","title":"SaguaroTrader.withdraw_funds!","text":"withdraw_funds!(broker::Broker, amount::Real)\n\nwithdraw_funds!(broker::Broker, amount::Real, currency::String)\n\nWithdraw funds from broker\n\nParameters\n\nbroker::Broker\namount::Real\ncurrency::String\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.subscribe_funds_to_portfolio!","page":"API","title":"SaguaroTrader.subscribe_funds_to_portfolio!","text":"subscribe_funds_to_portfolio!(broker::Broker, portfolio_id::String, amount::Real)\n\nAdd funds to portfolio from the broker\n\nParameters\n\nbroker::Broker\nportfolio_id::String\namount::Real\n\n\n\n\n\n","category":"function"},{"location":"api/#SaguaroTrader.withdraw_funds_from_portfolio!","page":"API","title":"SaguaroTrader.withdraw_funds_from_portfolio!","text":"withdraw_funds_from_portfolio!(broker::Broker, portfolio_id::String, amount::Real)\n\nWithdraw funds from portfolio into the broker\n\nParameters\n\nbroker::Broker\nportfolio_id::String\namount::Real\n\n\n\n\n\n","category":"function"},{"location":"api/#Order-Sizer","page":"API","title":"Order Sizer","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"OrderSizer\nDollarWeightedOrderSizer\nLongShortOrderSizer","category":"page"},{"location":"api/#SaguaroTrader.OrderSizer","page":"API","title":"SaguaroTrader.OrderSizer","text":"Create target asset quantities for portfolios\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.DollarWeightedOrderSizer","page":"API","title":"SaguaroTrader.DollarWeightedOrderSizer","text":"Create target portfolio quantities using the total equity available to the order sizer.\n\nFields\n\nbroker::Broker\nportfolio_id::String\ncash_buffer_percentage::Float64=0.05\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.LongShortOrderSizer","page":"API","title":"SaguaroTrader.LongShortOrderSizer","text":"Create target portfolio quantities using the total equity available to the order sizer.\n\nFields\n\nbroker::Broker\nportfolio_id::String\ngross_leverage::Float64=1.0\n\n\n\n\n\n","category":"type"},{"location":"api/#Portfolio-Construction-Model","page":"API","title":"Portfolio Construction Model","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"PortfolioConstructionModel","category":"page"},{"location":"api/#SaguaroTrader.PortfolioConstructionModel","page":"API","title":"SaguaroTrader.PortfolioConstructionModel","text":"Struct needed to generate target portfolio weights\n\nFields\n\nbroker::Broker\nportfolio_id::String\nuniverse::Universe\norder_sizer::OrderSizer\nportfolio_optimizer::PortfolioOptimizer\nalpha_model::AlphaModel\n\n\n\n\n\n","category":"type"},{"location":"api/#Rebalance","page":"API","title":"Rebalance","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Rebalance\nBuyAndHoldRebalance\nDailyRebalance\nMonthlyRebalance","category":"page"},{"location":"api/#SaguaroTrader.Rebalance","page":"API","title":"SaguaroTrader.Rebalance","text":"Rebalance periods for backtesting\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.BuyAndHoldRebalance","page":"API","title":"SaguaroTrader.BuyAndHoldRebalance","text":"Only rebalance at the start date\n\nFields\n\nstart_dt::DateTime\nrebalances::Vector{DateTime}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.DailyRebalance","page":"API","title":"SaguaroTrader.DailyRebalance","text":"Rebalance daily\n\nFields\n\nstart_date::Date\nend_date::Date\nmarket_time::DateTime\nrebalances::Vector{DateTime}\n\n\n\n\n\n","category":"type"},{"location":"api/#SaguaroTrader.MonthlyRebalance","page":"API","title":"SaguaroTrader.MonthlyRebalance","text":"Rebalance monthly\n\nFields\n\nstart_date::Date\nend_date::Date\nmarket_time::DateTime\nrebalances::Vector{DateTime}\n\n\n\n\n\n","category":"type"},{"location":"examples/#Examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/#%-Equities,-40%-Bonds","page":"Examples","title":"60% Equities, 40% Bonds","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"# https://github.com/mhallsmoore/qstrader/blob/master/examples/sixty_forty.py\nusing SaguaroTrader\nusing SaguaroTraderResults\nusing CSV\nusing DataFrames\nusing MarketData\nusing Plots\n\nstart_dt = DateTime(2005, 1, 1)\nend_dt = DateTime(2022, 9, 1)\ninitial_cash = 100_000.0\n\n#####################################################\n# Download market data\n######################################################\nfunction download_market_data(\n    securities::Vector{Symbol},\n    data_dir::String = \"./temp/\";\n    start_dt::DateTime = DateTime(1990, 1, 1),\n    end_dt::DateTime = DateTime(2040, 1, 1),\n)\n    if !isdir(data_dir)\n        mkdir(data_dir)\n    end\n    for security in securities\n        df = yahoo(security, YahooOpt(period1 = start_dt, period2 = end_dt)) |> DataFrame\n        CSV.write(joinpath(data_dir, \"$security.csv\"), df)\n    end\n    return nothing\nend\n\n\nif !isfile(\"./temp/AGG.csv\") & !isfile(\"./temp/SPY.csv\")\n    download_market_data([:SPY, :AGG]; start_dt = start_dt)\nend\n\n#####################################################\n# Prepare broker\n######################################################\n# configure data source, portfolio optimizer\ndata_source = CSVDailyBarSource(\"./temp/\")\ndata_handler = BacktestDataHandler([data_source])\nport_optimizer = FixedWeightPortfolioOptimizer(data_handler)\n\n# create exchange, broker\nexchange = SimulatedExchange(start_dt)\nbroker = SimulatedBroker(start_dt, exchange, data_handler; initial_cash = initial_cash * 2)\n\n#####################################################\n# 60% SPY, 40% AAG (bonds)\n######################################################\n\n# construct asset universe, weights\nassets = [Equity(:SPY), Equity(:AGG)]\nuniverse = StaticUniverse(assets)\nsignal_weights = Dict(Equity(:SPY) => 0.6, Equity(:AGG) => 0.4)\nalpha_model = FixedSignalsAlphaModel(signal_weights)\n\n# Configure portfolio\ncreate_portfolio!(broker, initial_cash; portfolio_id = \"sixty_forty\")\norder_sizer = DollarWeightedOrderSizer(0.001)\nrebalance = BuyAndHoldRebalance(Date(start_dt))\n\n# Run 60/40 backtest\nstrategy_trading_session = BacktestTradingSession(\n    start_dt,\n    end_dt,\n    universe,\n    broker,\n    alpha_model,\n    rebalance,\n    portfolio_id,\n    order_sizer,\n    port_optimizer,\n)\nrun!(strategy_trading_session)\n\n#####################################################\n# SPY Benchmark\n######################################################\n# Configure portfolio\ncreate_portfolio!(broker, initial_cash; portfolio_id = \"spy_benchmark\")\n\n# configure weights, order sizer, rebalance frequency\nsignal_weights = Dict(Equity(:SPY) => 1.0)\nalpha_model = FixedSignalsAlphaModel(signal_weights)\norder_sizer = DollarWeightedOrderSizer(0.001)\nrebalance = BuyAndHoldRebalance(Date(start_dt))\n\n# Run SPY backtest\nbenchmark_trading_session = BacktestTradingSession(\n    start_dt,\n    end_dt,\n    universe,\n    broker,\n    alpha_model,\n    rebalance,\n    portfolio_id,\n    order_sizer,\n    port_optimizer,\n)\nrun!(benchmark_trading_session)\n\n\n#####################################################\n# Plot results\n######################################################\nplt_tearsheet = SaguaroTraderResults.plot_tearsheet(\n    strategy_trading_session,\n    benchmark_trading_session;\n    title = \"60/40 Backtest Results vs S&P 500\",\n)\nsavefig(plt_tearsheet, \"./tearsheet.png\")","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"(Image: 60/40 Tearsheet)","category":"page"},{"location":"#SaguaroTrader.jl-Docs","page":"Home","title":"SaguaroTrader.jl Docs","text":"","category":"section"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"From the Julia General Registry:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ]  # enters the pkg interface\npkg> add SaguaroTrader","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg; Pkg.add(\"SaguaroTrader\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"From source:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Pkg; Pkg.add(url=\"https://github.com/SaguaroCapital/SaguaroTrader.jl/\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> ]  # enters the pkg interface\nPkg> add https://github.com/SaguaroCapital/SaguaroTrader.jl/","category":"page"}]
}
