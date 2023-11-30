
@testset "Order Sizer" begin
    ds = CSVDailyBarSource("./test_data")
    dh = BacktestDataHandler([ds])
    broker = SimulatedBroker(
        DateTime(2020), SimulatedExchange(DateTime(2020)), dh; initial_cash=100_000.0
    )
    create_portfolio!(broker, 75_000; portfolio_id="test_port")

    # dollar weighted
    order_sizer = DollarWeightedOrderSizer(0.01)
    weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 2.0)
    target_portfolio = order_sizer(
        broker, "test_port", weights, DateTime(2019, 4, 9, 14, 30)
    )
    @test target_portfolio[Equity(:AMD)] == 876
    @test target_portfolio[Equity(:INTC)] == 894

    # long-short
    order_sizer = LongShortOrderSizer(2.0)
    weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 2.0)
    target_portfolio = order_sizer(
        broker, "test_port", weights, DateTime(2019, 4, 9, 14, 30)
    )
    @test target_portfolio[Equity(:AMD)] == 1770
    @test target_portfolio[Equity(:INTC)] == 1806
end
