
#TODO: Do we need this, or just a data handler?
"""
Data Handler for backtesting
Fields
------
- `data_sources
"""
struct BacktestDataHandler <: DataHandler
    data_sources::Any
    function BacktestDataHandler(data_sources)
        _verify_unique_assets(data_sources)
        return new(data_sources)
    end
end

"""
When getting latest asset bid/ask prices,
we use the first one we find for the asset,
so this assumes that each asset is only present 
in one data source.
"""
function _verify_unique_assets(data_sources)
    n_data_sources = size(data_sources, 1)
    if n_data_sources == 1
        return nothing
    end

    for ds1_ix in 1:(n_data_sources - 1)
        for ds2_ix in 2:(n_data_sources)
            ds1 = data_sources[ds1_ix]
            ds2 = data_sources[ds2_ix]
            for key in keys(ds1.dict_asset_dfs)
                try # check if asset is in both ds
                    ds2.dict_asset_dfs[key]
                    @warn "$key appears in multiple data sources. The first bid/ask value will be used."
                catch
                    continue
                end
            end
        end
    end
    return nothing
end

function get_asset_latest_bid_price(dh::DataHandler, dt::DateTime, asset::Symbol)
    bid = float(NaN)
    for ds in dh.data_sources
        try
            bid = get_bid(ds, dt, asset)
            if !isnan(bid)
                return bid
            end
        catch
            continue
        end
    end
    return bid
end

function get_asset_latest_ask_price(dh::DataHandler, dt::DateTime, asset::Symbol)
    ask = float(NaN)
    for ds in dh.data_sources
        try
            ask = get_ask(ds, dt, asset)
            if !isnan(ask)
                return ask
            end
        catch
            continue
        end
    end
    return ask
end

function get_asset_latest_volume(dh::DataHandler, dt::DateTime, asset::Symbol)
    bid = float(NaN)
    for ds in dh.data_sources
        try
            bid = get_volume(ds, dt, asset)
            if !isnan(bid)
                return bid
            end
        catch
            continue
        end
    end
    return bid
end

function get_asset_latest_bid_ask_price(dh::DataHandler, dt::DateTime, asset::Symbol)
    bid = get_asset_latest_bid_price(dh, dt, asset)
    ask = get_asset_latest_ask_price(dh, dt, asset)
    return bid, ask
end

function get_asset_latest_mid_price(dh::DataHandler, dt::DateTime, asset::Symbol)
    bid, ask = get_asset_latest_bid_ask_price(dh, dt, asset)
    return (bid + ask) / 2.0
end

function get_assets_historical_range_close_price(dh::DataHandler, start_dt::DateTime,
                                                 end_dt::DateTime,
                                                 assets::AbstractVector{Symbol})
    df_prices = DataFrame(; timestamp=Vector{DateTime})
    for ds in dh.data_sources
        df_prices_temp = get_assets_historical_bids(ds, start_dt, end_dt, assets)
        if size(df_prices_temp, 1) > 0
            df_prices = outerjoin(df_prices, df_prices_temp; on=:timestamp)
        end
    end
    return df_prices
end

"""
Get a vector of all unique days where
pricing data exists
"""
function _get_unique_pricing_events(dh::DataHandler, start_dt::DateTime=DateTime(1900),
                                    end_dt::DateTime=DateTime(2100))
    df_events = DataFrame(; timestamp=Vector{DateTime}(), event_type=Vector{Symbol}())
    for ds in dh.data_sources
        df_ds_events = _get_unique_pricing_events(ds)
        time_mask = (df_ds_events.timestamp .>= start_dt) .&
                    (df_ds_events.timestamp .<= end_dt)
        df_ds_events = df_ds_events[time_mask, :]
        df_events = unique(vcat(df_events, df_ds_events))
    end
    return sort(df_events)
end

"""
```julia
get_asset_latest_bid_price(dh::DataHandler, dt::DateTime, asset::Symbol)
```

Get the bid price for an asset at a certain time.

Parameters
----------
- `dh::DataHandler`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Float64`: bid for an asset at the given datetime
"""
get_asset_latest_bid_price

"""
```julia
get_asset_latest_ask_price(dh::DataHandler, dt::DateTime, asset::Symbol)
```

Get the ask price for an asset at a certain time.

Parameters
----------
- `dh::DataHandler`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Float64`: ask for an asset at the given datetime
"""
get_asset_latest_ask_price

"""
```julia
get_asset_latest_bid_ask_price(dh::DataHandler, dt::DateTime, asset::Symbol)
```

Get the bid, ask price for an asset at a certain time.

Parameters
----------
- `dh::DataHandler`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Tuple{Float64, Float64}`: (bid, ask) for an asset at the given datetime
"""
get_asset_latest_bid_ask_price

"""
```julia
get_asset_latest_mid_price(dh::DataHandler, dt::DateTime, asset::Symbol)
```

Get the average of bid/ask price for an asset at a certain time.

Parameters
----------
- `dh::DataHandler`
- `dt::DateTime`
- `asset::Symbol`

Returns
-------
- `Float64`: mid point between bid/ask for an asset at the given datetime
"""
get_asset_latest_mid_price

"""
```julia
get_assets_historical_range_close_price(
    dh::DataHandler,
    start_dt::DateTime,
    end_dt::DateTime,
    assets::AbstractVector{Symbol},
)  
```

All closing prices for the given assets in the given timerange

Parameters
----------
- `dh::DataHandler`
- `start_dt::DateTime`
- `end_dt::DateTime`
- `asset::AbstractVector{Symbol}`

Returns
-------
- `DataFrame`: dataframe of close prices for the assets
"""
get_assets_historical_range_close_price
