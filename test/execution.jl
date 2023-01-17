
@testset "Execution" begin
    ds = CSVDailyBarSource("./test_data")
    dh = BacktestDataHandler([ds])
    assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA)]
    uni = StaticUniverse(assets)
    port_optimizer = EqualWeightPortfolioOptimizer(dh)
    broker = SimulatedBroker(
        DateTime(2020),
        SimulatedExchange(DateTime(2020)),
        dh;
        initial_cash = 100_000.0,
    )
    create_portfolio!(broker, 75_000; portfolio_id = "test_port")
    order_sizer = DollarWeightedOrderSizer(0.01)
    signal_weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
    alpha_model = FixedSignalsAlphaModel(signal_weights)

    pcm = PortfolioConstructionModel(
        broker,
        "test_port",
        uni,
        order_sizer,
        port_optimizer,
        alpha_model,
    )
    dt = DateTime(2020, 1, 6, 14, 30)
    rebalance_orders = SaguaroTrader._create_rebalance_orders(pcm, dt)

    # submit orders
    exec_handler = SaguaroTrader.ExecutionHandler(broker, "test_port"; submit_orders = true)
    exec_handler(rebalance_orders)
    @test length(keys(broker.portfolios["test_port"].pos_handler.positions)) == 0
    SaguaroTrader.update!(broker, DateTime(2020, 1, 6, 14, 30))
    @test length(keys(broker.portfolios["test_port"].pos_handler.positions)) == 2

    # dont submit orders
    broker = SimulatedBroker(
        DateTime(2020),
        SimulatedExchange(DateTime(2020)),
        dh;
        initial_cash = 100_000.0,
    )
    create_portfolio!(broker, 75_000; portfolio_id = "test_port")
    exec_handler =
        SaguaroTrader.ExecutionHandler(broker, "test_port"; submit_orders = false)
    exec_handler(rebalance_orders)
    @test length(keys(broker.portfolios["test_port"].pos_handler.positions)) == 0
    SaguaroTrader.update!(broker, DateTime(2020, 1, 6, 14, 30))
    @test length(keys(broker.portfolios["test_port"].pos_handler.positions)) == 0

end
