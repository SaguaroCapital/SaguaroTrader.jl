
function _csv_file_to_symbol(csv_file::String)
    return (x -> Symbol(replace(x[end], ".csv" => "")))(splitpath(csv_file))
end

function _load_csv_into_df(
    csv_file::String,
    adjust_prices::Bool,
    market_open::Dates.CompoundPeriod=Hour(14) + Minute(30),
    market_close::Dates.CompoundPeriod=Hour(21) + Minute(59),
    start_dt::DateTime=DateTime(1900),
    end_dt::DateTime=DateTime(2100);
    time_col::Symbol=:timestamp,
    open_col::Symbol=:Open,
    close_col::Symbol=:Close,
)
    df = DataFrame(CSV.File(csv_file))
    mask = (df[:, time_col] .>= start_dt) .& (df[:, time_col] .<= end_dt)
    df = df[mask, :]
    return _convert_bar_frame_into_df_bid_ask(
        df;
        adjust_prices=adjust_prices,
        market_open=market_open,
        market_close=market_close,
        time_col=time_col,
        open_col=open_col,
        close_col=close_col,
    )
end

function _load_csvs_into_dfs(
    csv_files::Vector{String},
    adjust_prices::Bool=false,
    market_open::Dates.CompoundPeriod=Hour(14) + Minute(30),
    market_close::Dates.CompoundPeriod=Hour(21) + Minute(59),
    start_dt=DateTime(1900),
    end_dt=DateTime(2100);
    time_col::Symbol=:timestamp,
    open_col::Symbol=:Open,
    close_col::Symbol=:Close,
)
    dict_asset_dfs = Dict{Symbol,DataFrame}()
    for file in csv_files
        dict_asset_dfs[_csv_file_to_symbol(file)] = _load_csv_into_df(
            file,
            adjust_prices,
            market_open,
            market_close,
            start_dt,
            end_dt;
            time_col,
            open_col,
            close_col,
        )
    end
    return dict_asset_dfs
end

function _detect_adj_column(columns::Vector{String}, identifier::String)
    identifier = lowercase(identifier)
    for col in columns
        col_lowered = lowercase(col)
        if occursin("adj", col_lowered)
            if occursin(identifier, col_lowered)
                return col
            end
        end
    end

    # if we dont have a match, return the non adjusted column
    for col in columns
        col_lowered = lowercase(col)
        if identifier == col_lowered
            return col
        end
    end
    return error("Unable to detect '$identifier' column in columns: $columns")
end

"""
Estimate Bid-Ask spreads from OHLCV data

Parameters
----------
- `df_bar`::String
    The daily 'bar' OHLCV DataFrame.

Returns
-------
`DataFrame`
    The individually-timestamped open/closing prices, optionally
            adjusted for corporate actions
"""
function _convert_bar_frame_into_df_bid_ask(
    df_bar::DataFrame;
    adjust_prices::Bool=true,
    market_open::Dates.CompoundPeriod=Hour(14) + Minute(30),
    market_close::Dates.CompoundPeriod=Hour(20) + Minute(59),
    time_col::Symbol=:timestamp,
    open_col::Symbol=:Open,
    close_col::Symbol=:Close,
)
    sort!(df_bar, time_col)

    # create open/close df
    if adjust_prices
        cols = names(df_bar)
        adj_open_column = _detect_adj_column(cols, "open")
        adj_close_column = _detect_adj_column(cols, "close")
        df_oc = df_bar[:, [time_col, open_col, close_col, adj_close_column]]
        df_oc[:, adj_open_column] =
            (df_oc[:, adj_close_column] ./ df_oc[:, close_col]) .* df_oc[:, open_col]
        select!(df_oc, [time_col, adj_open_column, adj_close_column])
        DataFrames.rename!(
            df_oc, adj_open_column => open_col, adj_close_column => close_col
        )
    else
        df_oc = select(df_bar, [time_col, open_col, close_col])
    end
    dropmissing!(df_oc)

    # Convert bars into separate rows for open/close prices
    # appropriately timestamped
    df_open = select(df_oc, [time_col, open_col])
    df_open[!, time_col] = DateTime.(df_open[!, time_col]) .+ market_open
    df_open[:, :event_type] .= :market_open
    df_close = select(df_oc, [time_col, close_col])
    df_close[!, time_col] = DateTime.(df_close[!, time_col]) .+ market_close
    df_close[:, :event_type] .= :market_close

    # rename open, close, time columns
    DataFrames.rename!(df_open, open_col::Symbol => :Ask)
    DataFrames.rename!(df_close, close_col::Symbol => :Ask)
    DataFrames.rename!(df_close, time_col => :timestamp)

    # fill 0 open/close values with the other
    #TODO: should we do this?
    df_open[df_open.Ask .== 0.0, :Ask] = df_close[df_open.Ask .== 0.0, :Ask]
    df_close[df_close.Ask .== 0.0, :Ask] = df_open[df_close.Ask .== 0.0, :Ask]

    # create bid/ask df
    df_bid = vcat(df_open, df_close; cols=:union)
    sort!(df_bid, time_col)
    if any(ismissing.(df_bid.Ask))
        df_bid = transform(
            df_bid,
            "Ask" .=> x -> impute(x, LOCF(; limit=nothing); dims=:cols);
            renamecols=false,
        )
    end
    df_bid.Bid = df_bid.Ask

    return df_bid
end

"""
Encapsulates loading, preparation and querying of CSV files of
daily 'bar' OHLCV data. The CSV files are converted into a intraday
timestamped Pandas DataFrame with opening and closing prices.

Optionally utilises adjusted closing prices (if available) to
adjust both the close and open.

Fields
------
- `csv_dir::String`
    The full path to the directory where the CSV is located.
- `asset_type::String`
    The asset type that the price/volume data is for.
- `adjust_prices::String`
    Whether to utilise corporate-action adjusted prices for both
    the open and closing prices. Defaults to True.
- `csv_symbols::Vector`
    An optional list of CSV symbols to restrict the data source to.
    The alternative is to convert all CSVs found within the
    provided directory.
- `dict_asset_dfs::Dict{Symbol, DataFrame}`
    Automatically generated dictionary of asset symbols, and 
    pricing dataframes
"""
struct CSVDailyBarSource <: DataSource
    csv_dir::String
    asset_type::DataType
    adjust_prices::Bool
    assets::Vector{Asset}
    dict_asset_dfs::Dict{Symbol,DataFrame}
    csv_symbols::Union{Nothing,Vector{Symbol}}
    market_open::Dates.CompoundPeriod
    market_close::Dates.CompoundPeriod
    function CSVDailyBarSource(
        csv_dir::String;
        asset_type::DataType=Equity,
        adjust_prices::Bool=false,
        csv_symbols::Union{Nothing,Vector{Symbol}}=nothing,
        market_open::Dates.CompoundPeriod=Hour(14) + Minute(30),
        market_close::Dates.CompoundPeriod=Hour(20) + Minute(59),
        start_dt::DateTime=DateTime(1900),
        end_dt::DateTime=DateTime(2100),
        time_col::Symbol=:timestamp,
        open_col::Symbol=:Open,
        close_col::Symbol=:Close,
    )
        @assert start_dt < end_dt "Start Date $start_dt must be before $end_dt"
        csv_files = [joinpath(csv_dir, i) for i in readdir(csv_dir) if occursin(".csv", i)]
        if !isnothing(csv_symbols)
            csv_files = [
                i for i in csv_files if any(_csv_file_to_symbol(i) .== csv_symbols)
            ]
        else
            csv_symbols = [_csv_file_to_symbol(i) for i in csv_files]
        end
        dict_asset_dfs = _load_csvs_into_dfs(
            csv_files,
            adjust_prices,
            market_open,
            market_close,
            start_dt,
            end_dt;
            time_col,
            open_col,
            close_col,
        )
        assets = [asset_type(Symbol(asset)) for asset in csv_symbols]
        return new(
            csv_dir,
            asset_type,
            adjust_prices,
            assets,
            dict_asset_dfs,
            csv_symbols,
            market_open,
            market_close,
        )
    end
end

function get_bid(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)::Float64
    df_bid_ask = ds.dict_asset_dfs[asset]
    ix = searchsortedfirst(df_bid_ask.timestamp::Vector{DateTime}, dt)::Int64
    if (ix == 1) || (ix > size(df_bid_ask, 1))
        return NaN
    else
        return @inbounds df_bid_ask[ix, :Bid]::Float64
    end
end

function get_ask(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)::Float64
    df_bid_ask = ds.dict_asset_dfs[asset]
    ix = searchsortedfirst(df_bid_ask.timestamp::Vector{DateTime}, dt)::Int64
    if (ix == 1) || (ix > size(df_bid_ask, 1))
        return NaN
    else
        return @inbounds df_bid_ask[ix, :Ask]::Float64
    end
end

function _get_timestamp_start(start_dt::DateTime, v::Vector{DateTime})::keytype(v)
    start_ix = findfirst(>=(start_dt), v)
    if start_ix === nothing
        return firstindex(v)
    else
        return start_ix
    end
end

function _get_timestamp_end(end_dt::DateTime, v::Vector{DateTime})::keytype(v)
    end_ix = findlast(<=(end_dt), v)
    if end_ix === nothing
        return firstindex(v)
    else
        return end_ix
    end
end

function get_assets_historical_bids(
    ds::CSVDailyBarSource, start_dt::DateTime, end_dt::DateTime, assets::Vector{Symbol}
)
    # TODO: do we want historical close like qstrader uses?
    prices_df = DataFrame(; timestamp=Vector{DateTime}())
    dict_keys = keys(ds.dict_asset_dfs)
    for asset in assets
        if !(asset in dict_keys)
            continue
        end
        df_bid_ask = ds.dict_asset_dfs[asset]
        timestamp = df_bid_ask.timestamp::Vector{DateTime}
        start_ix = _get_timestamp_start(start_dt, timestamp)
        end_ix = _get_timestamp_end(end_dt, timestamp)
        df_bid_ask_subset = df_bid_ask[start_ix:end_ix, [:timestamp, :Bid]]::DataFrame
        if size(df_bid_ask_subset, 1) > 0
            DataFrames.rename!(df_bid_ask_subset, :Bid => asset)
            prices_df = outerjoin(prices_df, df_bid_ask_subset; on=:timestamp)::DataFrame
        end
    end
    return prices_df
end

"""
Get a vector of all unique days where
pricing data exists
"""
function _get_unique_pricing_events(ds::CSVDailyBarSource)
    df_events = DataFrame(; timestamp=Vector{DateTime}(), event_type=Vector{Symbol}())
    for asset in ds.assets
        df_current_events = ds.dict_asset_dfs[asset.symbol][:, [:timestamp, :event_type]]
        df_events = unique(vcat(df_events, df_current_events))
    end
    return sort(df_events)
end

"""
```julia
get_bid(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)
```

Get the bid price for an asset at a certain time.

Parameters
----------
- `ds::CSVDailyBarSource`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Float64`: bid for an asset at the given datetime
"""
get_bid

"""
```julia
get_ask(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)
```

Get the ask price for an asset at a certain time.

Parameters
----------
- `ds::CSVDailyBarSource`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Float64`: ask for an asset at the given datetime
"""
get_ask

"""
```julia
get_ask(ds::CSVDailyBarSource, dt::DateTime, asset::Symbol)
```

Obtain a multi-asset historical range of closing prices as a DataFrame

Parameters
----------
- `ds::CSVDailyBarSource`
- `start_dt::DateTime`
- `end_dt::DateTime`
- `asset::Symbol`

Returns
-------
- `DataFrame`: Dataframe with the bid timestamps, asset symbols, and
"""
get_assets_historical_bids
