
@testset "FeeModel" begin
    # ZeroFeeModel
    fee_model = ZeroFeeModel()
    @test calculate_fee(fee_model, 100.0, 10.0) == 0.0

    # Percent fee model
    fee_model = PercentFeeModel(; tax_pct = 0.15)
    @test calculate_fee(fee_model, 100.0, 10.0) == 1.50
    fee_model = PercentFeeModel(; fee_pct = 0.10)
    @test calculate_fee(fee_model, 100.0, 10.0) == 1.0
    fee_model = PercentFeeModel(; tax_pct = 0.15, fee_pct = 0.10)
    @test calculate_fee(fee_model, 100.0, 10.0) == 2.50
    fee_model = PercentFeeModel()
    @test calculate_fee(fee_model, 100.0, 10.0) == 0.0

end
