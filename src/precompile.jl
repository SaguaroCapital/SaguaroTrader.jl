using SnoopPrecompile

@precompile_setup begin
    # Putting some things in `setup` can reduce the size of the
    # precompile file and potentially make loading faster.
    portfolio_id = "test_port"
    start_dt = DateTime(2020, 1, 1)
    end_dt = DateTime(2020, 12, 31)

    @precompile_all_calls begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)

        # This was just taking from test/backtest.jl
        # Better precompile should be done, but this significantly reduced latency
        # Especially 

        assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA)]
        universe = StaticUniverse(assets)
        # This brings the CSVDailyBarSource test from 5s to 0.3s on v1.9-rc1
        ds = CSVDailyBarSource("./test/test_data") #TODO: should we just hardcode an example df?
        dh = BacktestDataHandler([ds])
        port_optimizer = EqualWeightPortfolioOptimizer(dh)
        broker = SimulatedBroker(
            DateTime(2020), SimulatedExchange(DateTime(2020)), dh; initial_cash=100_000.0
        )
        create_portfolio!(broker, 75_000; portfolio_id=portfolio_id)
        order_sizer = DollarWeightedOrderSizer(0.01)
        signal_weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
        alpha_model = FixedSignalsAlphaModel(signal_weights)
        port_optimizer = FixedWeightPortfolioOptimizer(dh)
        rebalance = DailyRebalance(Date(start_dt), Date(end_dt))

        trading_session = BacktestTradingSession(
            start_dt,
            end_dt,
            universe,
            broker,
            alpha_model,
            rebalance,
            portfolio_id,
            order_sizer,
            port_optimizer,
        )
        run!(trading_session)
    end
end
