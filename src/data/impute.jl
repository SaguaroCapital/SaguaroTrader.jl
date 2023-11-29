"""
Impute utility functions to reduce dependencies
Code from: https://github.com/invenia/Impute.jl
"""

abstract type Imputor end

function Base.hash(imp::T, h::UInt) where T <: Imputor
    h = hash(Symbol(T), h)

    for f in fieldnames(T)
        h = hash(getfield(imp, f), h)
    end

    return h
end

function Base.:(==)(a::T, b::T) where T <: Imputor
    result = true

    for f in fieldnames(T)
        if !isequal(getfield(a, f), getfield(b, f))
            result = false
            break
        end
    end

    return result
end

function impute(data, imp::Imputor; kwargs...)
    # NOTE: We don't use a return type declaration here because `trycopy` isn't guaranteed
    # to return the same type passed in. For example, subarrays and subdataframes will
    # return a regular array or dataframe.
    return impute!(trycopy(data), imp; kwargs...)
end

function impute!(
    data::A, imp::Imputor; dims=:, kwargs...
)::A where A <: AbstractArray{Union{Any, Missing}}
    dims === Colon() && return _impute!(data, imp; kwargs...)

    for x in eachslice(data; dims=dims)
        _impute!(x, imp; kwargs...)
    end

    return data
end


function impute!(
    data::M, imp::Imputor; dims=nothing, kwargs...
)::M where M <: AbstractMatrix{Union{Any, Missing}}
    dims === Colon() && return _impute!(data, imp; kwargs...)
    # We're calling our `dim` function to throw a depwarn if `dims === nothing`
    d = dim(data, dims)

    for x in eachslice(data; dims=d)
        _impute!(x, imp; kwargs...)
    end

    return data
end

impute!(data::AbstractMatrix{Missing}, imp::Imputor; kwargs...) = data

"""
    impute!(data::T, imp; kwargs...) -> T where T <: AbstractVector{<:NamedTuple}

Special case rowtables which are arrays, but we want to fallback to the tables method.
"""
function impute!(data::T, imp::Imputor)::T where T <: AbstractVector{<:NamedTuple}
    return materializer(data)(impute!(Tables.columns(data), imp))
end

"""
    impute!(data::AbstractArray, imp) -> data


Just returns the `data` when the array doesn't contain `missing`s
"""
impute!(data::AbstractArray, imp::Imputor; kwargs...) = disallowmissing(data)

"""
    impute!(data::AbstractArray{Missing}, imp) -> data

Just return the `data` when the array only contains `missing`s
"""
impute!(data::AbstractArray{Missing}, imp::Imputor; kwargs...) = data



function impute!(table::T, imp::Imputor; cols=nothing)::T where T
    # TODO: We could probably handle iterators of tables here
    istable(table) || throw(MethodError(impute!, (table, imp)))

    # Extract a columns iterator that we should be able to use to mutate the data.
    # NOTE: Mutation is not guaranteed for all table types, but it avoid copying the data
    columntable = Tables.columns(table)

    cnames = cols === nothing ? propertynames(columntable) : cols
    for cname in cnames
        impute!(getproperty(columntable, cname), imp)
    end

    return table
end

struct LOCF <: Imputor
    limit::Union{UInt, Nothing}
end

LOCF(; limit=nothing) = LOCF(limit)

function _impute!(data::AbstractVector{Union{Any, Missing}}, imp::LOCF)
    @assert !all(ismissing, data)
    start_idx = findfirst(!ismissing, data)
    count = 1

    for i in start_idx + 1:lastindex(data)
        if ismissing(data[i])
            if imp.limit === nothing
                data[i] = data[i-1]
            elseif count <= imp.limit
                data[i] = data[start_idx]
                count += 1
            end
        else
            start_idx = i
            count = 1
        end
    end

    return data
end

function trycopy(data)
    # Not all objects support `copy`, but we should use it to improve
    # performance if possible.
    try
        copy(data)
    catch
        deepcopy(data)
    end
end

function dim(data, d)
    # Special case d === nothing as this currently signifies the default colwise
    # operations that are being deprecated.
    if d === nothing
        Base.depwarn(
            "Imputing on matrices will require specifying `dims=2` or `dims=:cols` in a " *
            "future release, to maintain the current behaviour.",
            :dim
        )
        return 2
    # Special case tables and matrices using the `:rows` and `:cols` dims values
    elseif d in (:rows, :cols) && (istable(data) || isa(data, AbstractMatrix))
        return NamedDims.dim((:rows, :cols), d)
    # Fallback to whatever NameDims gives us
    else
        return NamedDims.dim(NamedDims.dimnames(data), d)
    end
end

# Remove this once the corresponding statsbase pull request is merged and tagged.
# https://github.com/JuliaStats/StatsBase.jl/pull/611
_mode(a::AbstractArray) = mode(a)

function _mode(a::AbstractVector, wv::AbstractArray{T}) where T <: Real
    isempty(a) && throw(ArgumentError("mode is not defined for empty collections"))
    length(a) == length(wv) || throw(ArgumentError(
        "data and weight vectors must be the same size, got $(length(a)) and $(length(wv))"
    ))

    # Iterate through the data
    mv = first(a)
    mw = first(wv)
    weights = Dict{eltype(a), T}()
    for (x, w) in zip(a, wv)
        _w = get!(weights, x, zero(T)) + w
        if _w > mw
            mv = x
            mw = _w
        end
        weights[x] = _w
    end

    return mv
end