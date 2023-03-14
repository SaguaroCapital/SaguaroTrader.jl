
@testset "Rebalance" begin
    # Buy and hold
    rebalance = BuyAndHoldRebalance(Date(2022, 1, 1))
    @test rebalance.start_date == Date(2022, 1, 1)
    @test rebalance.rebalances[1] == DateTime(2022, 1, 1, 14, 30)
    @test size(rebalance.rebalances, 1) == 1
    rebalance = BuyAndHoldRebalance(DateTime(2022, 1, 1, 14, 30))
    @test rebalance.start_date == Date(2022, 1, 1)
    @test rebalance.rebalances[1] == DateTime(2022, 1, 1, 14, 30)
    @test size(rebalance.rebalances, 1) == 1

    # daily
    rebalance = DailyRebalance(Date(2022, 1, 1), Date(2022, 1, 5))
    @test rebalance.rebalances[1] == DateTime(2022, 1, 1, 14, 30)
    @test rebalance.rebalances[5] == DateTime(2022, 1, 5, 14, 30)
    @test size(rebalance.rebalances, 1) == 5

    # weekly
    rebalance = WeeklyRebalance(Date(2022, 1, 1), Date(2022, 3, 1))
    @test rebalance.rebalances[1] == DateTime(2022, 1, 3, 14, 30)
    @test rebalance.rebalances[end] == DateTime(2022, 2, 28, 14, 30)
    @test size(rebalance.rebalances, 1) == 9
    rebalance = WeeklyRebalance(Date(2022, 1, 1), Date(2022, 3, 1), 5)
    @test rebalance.rebalances[1] == DateTime(2022, 1, 7, 14, 30)
    @test rebalance.rebalances[end] == DateTime(2022, 2, 25, 14, 30)
    @test size(rebalance.rebalances, 1) == 8

    # monthly
    rebalance = MonthlyRebalance(Date(2022, 1, 1), Date(2022, 3, 1))
    @test size(rebalance.rebalances, 1) == 3
    rebalance = MonthlyRebalance(Date(2022, 1, 1), Date(2022, 3, 1), -1)
    @test size(rebalance.rebalances, 1) == 2
    rebalance = MonthlyRebalance(Date(2022, 1, 1), Date(2022, 3, 1), 15)
    @test size(rebalance.rebalances, 1) == 2
    rebalance = MonthlyRebalance(Date(2022, 1, 15), Date(2022, 3, 15), 1)
    @test size(rebalance.rebalances, 1) == 2
end
