using SnoopPrecompile

@precompile_setup begin
    # Putting some things in `setup` can reduce the size of the
    # precompile file and potentially make loading faster.
    portfolio_id = "test_port"
    start_dt = DateTime(2020, 1, 1)
    end_dt = DateTime(2020, 12, 31)
    signal_weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
    rolling_signal_weights = Dict(
        DateTime(2020) => Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0),
        DateTime(2021) => Dict(Equity(:INTC) => 1.0),
        DateTime(2022) => Dict(Equity(:AMD) => 1.0),
    )

    @precompile_all_calls begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)

        #####################################################################
        # Universe
        static_assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA), Cash()]
        uni = StaticUniverse(static_assets)

        # dynamic universe
        dynamic_assets = Dict(
            Equity(:AMD) => start_dt,
            Equity(:INTC) => start_dt,
            Equity(:NVDA) => start_dt,
            Cash() => start_dt,
        )
        uni = DynamicUniverse(dynamic_assets)
        _get_assets(uni, end_dt)

        #####################################################################
        # Order
        ord1 = Order(start_dt, 100.0, Equity(:AMD))
        ord2 = Order(start_dt, 100.0, Equity(:AMD))
        equal_orders(ord1, ord2)

        #####################################################################
        # Rebalance
        BuyAndHoldRebalance(Date(2022, 1, 1))
        WeeklyRebalance(Date(2022, 1, 1), Date(2022, 3, 1))
        MonthlyRebalance(Date(2022, 1, 1), Date(2022, 3, 1))

        #####################################################################
        # Exchange
        is_open(SimulatedExchange(start_dt), end_dt)
        is_open(AlwaysOpenExchange(start_dt), end_dt)

        #####################################################################
        # Fee Model
        calculate_fee(ZeroFeeModel(), 100.0, 10.0)
        calculate_fee(PercentFeeModel(; tax_pct=0.15, fee_pct=0.10), 100.0, 10.0)

        #####################################################################
        # Data

        #####################################################################
        # Portfolio
        create_subscription(DateTime(2022, 1, 1), 50.0, 100.0)
        create_withdrawal(DateTime(2022, 1, 1), 50.0, 100.0)
        create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, 1) # buy
        create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, -1) # sell

        port = Portfolio(DateTime(2022, 1, 1), 100_000.0, "USD")
        total_market_value(port)
        total_equity(port)
        total_unrealized_pnl(port)
        total_realized_pnl(port)
        total_pnl(port)
        subscribe_funds!(port, DateTime(2022, 2, 1), 50_000.0)
        withdraw_funds!(port, DateTime(2022, 2, 2), 50_000.0)
        txn = Transaction(Equity(:AMD), 10.0, DateTime(2022, 2, 2), 50.0, 0.1)
        transact_asset!(port, txn)

        #####################################################################
        # Alpha Model
        alpha_model = FixedSignalsAlphaModel(signal_weights)
        alpha_model(DateTime(2022, 1, 1))
        alpha_model = SingleSignalAlphaModel(StaticUniverse(static_assets), 1.0)
        alpha_model(DateTime(2022, 1, 1))
        alpha_model = RollingSignalsAlphaModel(rolling_signal_weights)
        alpha_model(DateTime(2022, 1, 1))
    end
end
