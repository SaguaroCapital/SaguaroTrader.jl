
function _impute_locf(data::AbstractVector{Union{Missing,Float64}})
    start_idx = findfirst(!ismissing, data)
    cnt = 1

    for i in (start_idx + 1):lastindex(data)
        if ismissing(data[i])
            data[i] = data[i - 1]
        else
            start_idx = i
            cnt = 1
        end
    end

    return convert(Vector{Float64}, data)
end

"""
Abstract type for a data source. 
"""
abstract type AbstractDataSource end
include("daily_bar_csv.jl")

"""
Abstract type for a data handler.
"""
abstract type AbstractDataHandler end
include("data_handler.jl")
