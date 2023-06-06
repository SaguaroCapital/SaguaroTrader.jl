
@testset "Slippage Model" begin
    # ZeroSlippageModel
    slippage_model = ZeroSlippageModel()
    price = 10.0
    @test slippage_model(-1; price) == 10.0
    @test slippage_model(1; price) == 10.0

    # FixedSlippageModel
    slippage_model = FixedSlippageModel(0.0)
    @test slippage_model(-1; price) == 10.0
    slippage_model = FixedSlippageModel(0.02)
    @test slippage_model(-1; price) == 9.99
    slippage_model = FixedSlippageModel(0.02)
    @test slippage_model(1; price) == 10.01

    # PercentSlippageModel
    slippage_model = PercentSlippageModel(0.0)
    @test slippage_model(-1; price) == 10.0
    slippage_model = PercentSlippageModel(0.2)
    @test slippage_model(-1; price) == 9.99
    slippage_model = PercentSlippageModel(0.2)
    @test slippage_model(1; price) == 10.01

    # VolumeSharesSlippageModel
    slippage_model = VolumeSharesSlippageModel(0.0)
    volume = 1e7
    order_quantity = 10_000.0
    @test slippage_model(-1; price, volume, order_quantity) == 10.0
    @test slippage_model(1; price, volume, order_quantity) == 10.0
    slippage_model = VolumeSharesSlippageModel(0.2)
    @test slippage_model(-1; price, volume, order_quantity) == 9.999998
    @test slippage_model(1; price, volume, order_quantity) == 10.000002
end
