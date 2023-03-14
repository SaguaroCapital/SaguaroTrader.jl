
@testset "Exchange" begin
    # simulated exchange
    exchange = SimulatedExchange(Date(2020, 1, 1))
    @test SaguaroTrader.is_open(exchange, DateTime(2020, 1, 1, 14, 30))
    @test !SaguaroTrader.is_open(exchange, DateTime(2020, 1, 1, 21, 00))
    @test !SaguaroTrader.is_open(exchange, DateTime(2019, 1, 1, 14, 30))

    # always open exchange
    exchange = AlwaysOpenExchange(Date(2020, 1, 1))
    @test SaguaroTrader.is_open(exchange, DateTime(2020, 1, 1, 14, 30))
    @test SaguaroTrader.is_open(exchange, DateTime(2020, 1, 1, 21, 00))
    @test !SaguaroTrader.is_open(exchange, DateTime(2019, 1, 1, 14, 30))
end
