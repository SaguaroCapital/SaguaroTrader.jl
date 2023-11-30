
@testset "Alpha Model" begin
    # fixed signals alpha model
    signal_weights = Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
    alpha_model = FixedSignalsAlphaModel(signal_weights)
    @test alpha_model(DateTime(2022, 1, 1)) == signal_weights

    # rolling signals
    dict_signal_weights = Dict(DateTime(2020) => Dict(Equity(:AMD) => 1.0,
                                                      Equity(:INTC) => 1.0),
                               DateTime(2021) => Dict(Equity(:INTC) => 1.0),
                               DateTime(2022) => Dict(Equity(:AMD) => 1.0))
    alpha_model = RollingSignalsAlphaModel(dict_signal_weights)
    @test alpha_model(DateTime(2019, 12, 31)) == Dict{Asset,Float64}()
    @test alpha_model(DateTime(2020, 1, 1)) ==
          Dict(Equity(:AMD) => 1.0, Equity(:INTC) => 1.0)
    @test alpha_model(DateTime(2021, 1, 1)) == Dict(Equity(:INTC) => 1.0)
    @test alpha_model(DateTime(2022, 1, 1)) == Dict(Equity(:AMD) => 1.0)

    # single signal
    assets = [Equity(:AMD), Equity(:INTC)]
    uni = StaticUniverse(assets)
    alpha_model = SingleSignalAlphaModel(uni, 1.0)
    @test alpha_model(DateTime(2022, 1, 1)) == signal_weights
end
