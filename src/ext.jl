

function download_market_data(args...; kwargs...)
    error_msg = """
    MarketData.jl is not installed in the current environment.
    Please install it by running the following commands in the Julia REPL:
    using Pkg
    Pkg.add("MarketData")
    """
    error(error_msg)
    return nothing
end
