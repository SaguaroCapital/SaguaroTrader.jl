
@testset "Order" begin
    ord1 = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    ord2 = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    ord3 = Order(DateTime(2022, 7, 1), -100.0, Equity(:AMD))
    ord4 = Order(DateTime(2023, 7, 1), 100.0, Equity(:AMD))
    ord5 = Order(DateTime(2023, 7, 1), 100.0, Equity(:NVDA))

    @test SaguaroTrader.equal_orders(ord1, ord2)
    @test !SaguaroTrader.equal_orders(ord1, ord3) # different quantity
    @test !SaguaroTrader.equal_orders(ord1, ord4) # different date
    @test !SaguaroTrader.equal_orders(ord1, ord5) # different asset
    @test ord1.direction == 1
    @test ord3.direction == -1
end
