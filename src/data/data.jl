
"""
Abstract type for a data source. 
"""
abstract type DataSource end
include("daily_bar_csv.jl")

"""
Abstract type for a data handler.
"""
abstract type DataHandler end
include("data_handler.jl")
