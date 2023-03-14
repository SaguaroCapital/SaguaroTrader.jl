
@testset "Portfolio Optimizer" begin
    ds = CSVDailyBarSource("./test_data"; csv_symbols=[:AMD, :NVDA])
    dh = BacktestDataHandler([ds])

    port_optimizer = FixedWeightPortfolioOptimizer(dh)
    initial_weights = Dict(:AMD => 1.0, :NVDA => 2.0)
    new_weights = SaguaroTrader.generate_weights(port_optimizer, initial_weights)
    @test new_weights == initial_weights

    port_optimizer = EqualWeightPortfolioOptimizer(dh)
    initial_weights = Dict(:AMD => 1.0, :NVDA => 2.0)
    new_weights = SaguaroTrader.generate_weights(port_optimizer, initial_weights)
    @test new_weights == Dict(:AMD => 0.5, :NVDA => 0.5)
end
