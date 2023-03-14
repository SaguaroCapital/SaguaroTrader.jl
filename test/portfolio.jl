
@testset "Transaction" begin
    txn = Transaction(Equity(:AMD), 10.0, DateTime(2021, 1, 1), 50.0, 0.1)

    @test SaguaroTrader.direction(txn) == 1
    @test cost_without_fee(txn) == 500.0
    @test cost_with_fee(txn) == 500.1

    txn = Transaction(Equity(:AMD), -10.0, DateTime(2021, 1, 1), 50.0, 0.1)

    @test SaguaroTrader.direction(txn) == -1
    @test cost_without_fee(txn) == -500.0
    @test cost_with_fee(txn) == -499.9
end

@testset "Position" begin
    # purchase quity, then sell some
    txn = Transaction(Equity(:AMD), 10.0, DateTime(2021, 1, 1), 50.0, 0.1)
    pos = position_from_transaction(txn)
    @test SaguaroTrader.direction(pos) == 1
    @test pos.net_quantity == 10.0
    txn = Transaction(Equity(:AMD), -5.0, DateTime(2021, 2, 1), 60.0, 0.1)
    SaguaroTrader.transact!(pos, txn)
    @test pos.net_quantity == 5.0
    @test SaguaroTrader.market_value(pos) == 300.0
    @test isapprox(SaguaroTrader.avg_price(pos), 50.01)
    @test SaguaroTrader.total_bought(pos) == 500.0
    @test SaguaroTrader.total_sold(pos) == 300.0
    @test SaguaroTrader.net_total(pos) == -200.0
    @test SaguaroTrader.net_incl_fee(pos) == -200.2
    @test SaguaroTrader.realized_pnl(pos) == 49.85
    @test isapprox(SaguaroTrader.unrealized_pnl(pos), 49.95)
    @test isapprox(SaguaroTrader.total_pnl(pos), 99.80)

    txn = Transaction(Equity(:AMD), -10.0, DateTime(2021, 1, 1), 50.0, 0.1)
    pos = position_from_transaction(txn)
    @test SaguaroTrader.direction(pos) == -1
    @test pos.net_quantity == -10.0
    txn = Transaction(Equity(:AMD), 5.0, DateTime(2021, 2, 1), 60.0, 0.1)
    SaguaroTrader.transact!(pos, txn)
    @test pos.net_quantity == -5.0
end

@testset "PositionHandler" begin
    pos_handler = PositionHandler()
    txn = Transaction(Equity(:AMD), 10.0, DateTime(2021, 1, 1), 50.0, 0.1)
    SaguaroTrader.transact_position!(pos_handler, txn)
    txn = Transaction(Equity(:NVDA), 10.0, DateTime(2021, 2, 1), 60.0, 0.1)
    SaguaroTrader.transact_position!(pos_handler, txn)
    txn = Transaction(Equity(:NVDA), -5.0, DateTime(2021, 2, 2), 70.0, 0.1)
    SaguaroTrader.transact_position!(pos_handler, txn)

    @test SaguaroTrader.total_market_value(pos_handler) == 850.0
    @test isapprox(SaguaroTrader.total_unrealized_pnl(pos_handler), 49.85)
    @test isapprox(SaguaroTrader.total_realized_pnl(pos_handler), 49.85)
    @test isapprox(SaguaroTrader.total_pnl(pos_handler), 99.7)

    delete!(pos_handler.positions, :AMD)
end

@testset "PortfolioEvent" begin
    pe = create_subscription(DateTime(2022, 1, 1), 50.0, 100.0)
    @test pe.type == "subscription"
    pe = create_withdrawal(DateTime(2022, 1, 1), 50.0, 100.0)
    @test pe.type == "withdrawal"
    pe = create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, 1)
    @test pe.type == "buy_asset"
    pe = create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, -1)
    @test pe.type == "sell_asset"
end

@testset "PortfolioEvent" begin
    pe = create_subscription(DateTime(2022, 1, 1), 50.0, 100.0)
    @test pe.type == "subscription"
    pe = create_withdrawal(DateTime(2022, 1, 1), 50.0, 100.0)
    @test pe.type == "withdrawal"
    pe = create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, 1)
    @test pe.type == "buy_asset"
    pe = create_asset_transaction(DateTime(2022, 1, 1), 50.0, 100.0, -1)
    @test pe.type == "sell_asset"
end

@testset "Portfolio" begin
    port = Portfolio(DateTime(2022, 1, 1), 100_000.0, "USD")
    @test total_market_value(port) == 0.0
    @test total_equity(port) == 100_000.0
    @test SaguaroTrader.total_unrealized_pnl(port) == 0.0
    @test SaguaroTrader.total_realized_pnl(port) == 0.0
    @test SaguaroTrader.total_pnl(port) == 0.0

    SaguaroTrader.subscribe_funds!(port, DateTime(2022, 2, 1), 50_000.0)
    @test total_equity(port) == 150_000.0
    SaguaroTrader.withdraw_funds!(port, DateTime(2022, 2, 2), 50_000.0)
    @test total_equity(port) == 100_000.0

    # simulate entering a pos and selling some
    txn = Transaction(Equity(:AMD), 10.0, DateTime(2022, 3, 1), 50.0, 0.1)
    SaguaroTrader.transact_asset!(port, txn)
    txn = Transaction(Equity(:AMD), -5.0, DateTime(2022, 3, 2), 70.0, 0.1)
    SaguaroTrader.transact_asset!(port, txn)
    @test total_market_value(port) == 350.0
    @test isapprox(total_equity(port), 100_199.8)
    @test isapprox(SaguaroTrader.total_unrealized_pnl(port), 99.95)
    @test isapprox(SaguaroTrader.total_realized_pnl(port), 99.85)
    @test isapprox(SaguaroTrader.total_pnl(port), 199.8)
end
