
@testset "Broker" begin
    ds = CSVDailyBarSource("./test_data")
    dh = BacktestDataHandler([ds])
    broker = SimulatedBroker(
        DateTime(2020),
        SimulatedExchange(DateTime(2020)),
        dh;
        initial_cash = 100_000.0,
    )
    create_portfolio!(broker, 75_000; portfolio_id = "test_port")
    @test broker.cash_balances[broker.base_currency] == 25_000.0
    create_portfolio!(broker; portfolio_id = "test_port2")
    @test broker.cash_balances[broker.base_currency] == 0.0

    order = Order(DateTime(2020, 1, 5), 100, Equity(:AMD))
    SaguaroTrader.submit_order!(broker, "test_port", order)
    @test length(broker.open_orders["test_port"]) == 1
    SaguaroTrader.update!(broker, DateTime(2020, 1, 6, 14, 30))
    @test length(broker.open_orders["test_port"]) == 0
    @test broker.portfolios["test_port"].cash == 70198.0

    subscribe_funds!(broker, 50_000)
    @test broker.cash_balances[broker.base_currency] == 50_000
    withdraw_funds!(broker, 25_000)
    @test broker.cash_balances[broker.base_currency] == 25_000

    subscribe_funds_to_portfolio!(broker, "test_port", 5_000)
    @test broker.portfolios["test_port"].cash == 75198.0
    withdraw_funds_from_portfolio!(broker, "test_port", 5_000)
    @test broker.portfolios["test_port"].cash == 70198.0

end
