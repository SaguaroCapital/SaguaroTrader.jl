
########################################################################
# DataSource
########################################################################
@testset "CSVDailyBarSource" begin
    # CSVDailyBarSource
    ds = CSVDailyBarSource(
        "./test_data/"; start_dt=DateTime(2019), end_dt=DateTime(2019, 2)
    )
    @test ds.csv_symbols == [:AAPL, :AMD, :INTC, :NVDA, :SPY]
    ds = CSVDailyBarSource("./test_data/"; csv_symbols=[:AMD, :NVDA])
    @test ds.csv_symbols == [:AMD, :NVDA]

    bid = get_bid(ds, DateTime(2019, 4, 9, 14, 30), :AMD)
    @test bid == 28.24

    ask = get_ask(ds, DateTime(2019, 4, 8, 21, 0), :AMD)
    @test ask == 28.24
    ask = get_ask(ds, DateTime(2019, 4, 9, 20, 59), :AMD)
    @test ask == 27.24

    unique_events = SaguaroTrader._get_unique_pricing_events(ds)
    @test size(unique_events, 1) == 9382
    @test size(unique_events) == size(unique(unique_events))
end

########################################################################
# DataHandler
########################################################################
@testset "DataHandler" begin
    ds1 = CSVDailyBarSource("./test_data"; csv_symbols=[:AMD, :NVDA])
    ds2 = CSVDailyBarSource("./test_data"; csv_symbols=[:SPY])
    dh = BacktestDataHandler([ds1, ds2])

    # bid, ask = get_asset_latest_bid_ask_price(dh, DateTime(2019, 4, 9, 14, 29), :AMD)
    # @test isnan(bid)
    # @test isnan(ask) #TODO: Do we want nan here?
    bid, ask = get_asset_latest_bid_ask_price(dh, DateTime(2019, 4, 9, 14, 30), :AMD)
    @test bid == 28.24
    @test ask == 28.24
    mid = get_asset_latest_mid_price(dh, DateTime(2019, 4, 9, 14, 30), :AMD)
    @test mid == 28.24

    df_prices = get_assets_historical_range_close_price(
        dh, DateTime(2019), DateTime(2020), [:AMD, :NVDA]
    )
    @test names(df_prices) == ["timestamp", "AMD", "NVDA"]

    unique_events = SaguaroTrader._get_unique_pricing_events(dh)
    @test size(unique_events, 1) == 9382
    @test size(unique_events) == size(unique(unique_events))
end
