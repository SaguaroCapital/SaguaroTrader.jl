
@testset "Order" begin
    ord1 = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    ord2 = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    ord3 = Order(DateTime(2022, 7, 1), -100.0, Equity(:AMD))

    @test SaguaroTrader.equal_orders(ord1, ord2)
    @test !SaguaroTrader.equal_orders(ord1, ord3)
    @test ord1.direction == 1
    @test ord3.direction == -1
end
