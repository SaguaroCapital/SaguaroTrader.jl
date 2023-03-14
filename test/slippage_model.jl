
@testset "Slippage Model" begin
    # FixedSlippageModel
    order = Order(DateTime(2022, 7, 1), -100.0, Equity(:AMD))
    slippage_model = FixedSlippageModel(0.0)
    @test slippage_model(order, 10.0) == 10.0
    slippage_model = FixedSlippageModel(0.02)
    @test slippage_model(order, 10.0) == 9.99
    order = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    slippage_model = FixedSlippageModel(0.02)
    @test slippage_model(order, 10.0) == 10.01

    # PercentSlippageModel
    order = Order(DateTime(2022, 7, 1), -100.0, Equity(:AMD))
    slippage_model = PercentSlippageModel(0.0)
    @test slippage_model(order, 10.0) == 10.0
    slippage_model = PercentSlippageModel(0.2)
    @test slippage_model(order, 10.0) == 9.99
    order = Order(DateTime(2022, 7, 1), 100.0, Equity(:AMD))
    slippage_model = PercentSlippageModel(0.2)
    @test slippage_model(order, 10.0) == 10.01
end
