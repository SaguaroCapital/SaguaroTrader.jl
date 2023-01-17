
@testset "BacktestTradingSession" begin
    assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA)]
    universe = StaticUniverse(assets)
    ds = CSVDailyBarSource("./test_data")
    dh = BacktestDataHandler([ds])
    port_optimizer = EqualWeightPortfolioOptimizer(dh)
    broker = SimulatedBroker(
        DateTime(2020),
        SimulatedExchange(DateTime(2020)),
        dh;
        initial_cash = 100_000.0,
    )
    portfolio_id = "test_port"
    create_portfolio!(broker, 75_000; portfolio_id = portfolio_id)
    order_sizer = DollarWeightedOrderSizer(0.01)
    signal_weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
    alpha_model = FixedSignalsAlphaModel(signal_weights)
    port_optimizer = FixedWeightPortfolioOptimizer(dh)
    start_dt = DateTime(2020, 1, 1)
    end_dt = DateTime(2020, 12, 31)
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
    @test size(trading_session.equity_curve, 1) == 253
end
