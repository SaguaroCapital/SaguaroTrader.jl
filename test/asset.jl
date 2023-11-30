
@testset "asset/universe" begin
    # static universe
    assets = [Equity(:AMD), Equity(:INTC), Equity(:NVDA), Cash()]
    uni = StaticUniverse(assets)
    @test assets == SaguaroTrader._get_assets(uni)

    # dynamic universe
    assets = Dict(Equity(:AMD) => Date(2020, 1, 1),
                  Equity(:INTC) => Date(2020, 6, 1),
                  Equity(:NVDA) => Date(2019, 3, 31),
                  Cash() => Date(2019, 1, 1))
    uni = DynamicUniverse(assets)
    res = SaguaroTrader._get_assets(uni, Date(2022, 1, 1))
    @test all(in(res).([Equity(:AMD), Equity(:INTC), Equity(:NVDA), Cash()]))
    res = SaguaroTrader._get_assets(uni, Date(2019, 5, 1))
    @test all(in(res).([Equity(:NVDA), Cash()]))
    @test [Cash()] == SaguaroTrader._get_assets(uni, Date(2019, 2, 1))
    @test Vector{Asset}() == SaguaroTrader._get_assets(uni, Date(2018, 1, 1))
end
