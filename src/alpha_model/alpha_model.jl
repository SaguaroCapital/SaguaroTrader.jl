
"""
Abstract type for alpha models
"""
abstract type AlphaModel end

include("fixed_signals.jl")
include("rolling_signals.jl")
include("single_signal.jl")
