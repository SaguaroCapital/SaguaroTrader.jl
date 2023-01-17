
@testset "PortfolioConstructionModel" begin
    assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA)]
    uni = StaticUniverse(assets)
    ds = CSVDailyBarSource("./test_data")
    dh = BacktestDataHandler([ds])
    port_optimizer = EqualWeightPortfolioOptimizer(dh)
    broker = SimulatedBroker(
        DateTime(2020),
        SimulatedExchange(DateTime(2020)),
        dh;
        initial_cash = 100_000.0,
    )
    create_portfolio!(broker, 75_000; portfolio_id = "test_port")
    order = Order(DateTime(2020, 1, 5), 100, Equity(:AMD))
    SaguaroTrader.submit_order!(broker, "test_port", order)
    order = Order(DateTime(2020, 1, 5), 100, Equity(:NVDA))
    SaguaroTrader.submit_order!(broker, "test_port", order)
    SaguaroTrader.update!(broker, DateTime(2020, 1, 6, 14, 30))
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
    nvda_order = [i for i in rebalance_orders if i.asset.symbol == :NVDA][1]
    @test nvda_order.quantity == -100
    intc_order = [i for i in rebalance_orders if i.asset.symbol == :INTC][1]
    @test intc_order.quantity == 623
    amd_order = [i for i in rebalance_orders if i.asset.symbol == :AMD][1]
    @test amd_order.quantity == 673
    @test amd_order.created_dt == dt

end
