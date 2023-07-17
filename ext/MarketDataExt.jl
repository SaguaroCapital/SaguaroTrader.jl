
module MarketDataExt

using CSV
using DataFrames
using Dates
using MarketData
using SaguaroTrader

function SaguaroTrader.download_market_data(
    security::Symbol,
    data_dir::String="./temp/";
    start_dt::DateTime=DateTime(1990, 1, 1),
    end_dt::DateTime=DateTime(2040, 1, 1),
)
    if !isdir(data_dir)
        mkdir(data_dir)
    end
    df = DataFrame(yahoo(security, YahooOpt(; period1=start_dt, period2=end_dt)))
    CSV.write(joinpath(data_dir, "$security.csv"), df)
    return nothing
end

function SaguaroTrader.download_market_data(
    securities::Vector{Symbol},
    data_dir::String="./temp/";
    start_dt::DateTime=DateTime(1990, 1, 1),
    end_dt::DateTime=DateTime(2040, 1, 1),
)
    if !isdir(data_dir)
        mkdir(data_dir)
    end
    for security in securities
        df = DataFrame(yahoo(security, YahooOpt(; period1=start_dt, period2=end_dt)))
        CSV.write(joinpath(data_dir, "$security.csv"), df)
    end
    return nothing
end

end # module
