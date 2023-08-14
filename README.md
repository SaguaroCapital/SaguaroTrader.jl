
# SaguaroTrader.jl

[![CI](https://github.com/SaguaroCapital/SaguaroTrader.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/SaguaroCapital/SaguaroTrader.jl/actions/workflows/CI.yml)
[![Lifecycle:Maturing](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Coverage](http://codecov.io/github/SaguaroCapital/SaguaroTrader.jl/coverage.svg?branch=main)](https://codecov.io/gh/SaguaroCapital/SaguaroTrader.jl)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://saguarocapital.github.io/SaguaroTrader.jl)

SaguaroTrader.jl is a flexible, schedule-driven backtesting library tailored for long-short equity and ETF-based systematic trading strategies. Signal generation operates independently from portfolio construction, risk management, execution, and simulated brokerage accounting. This library originated as a Julia port of the Python library [qstrader](https://github.com/mhallsmoore/qstrader).

## Installation

From the Julia General Registry:
```julia
julia> ]  # enters the pkg interface
pkg> add SaguaroTrader
```

```julia
julia> using Pkg; Pkg.add("SaguaroTrader")
```

From source:
```julia
julia> using Pkg; Pkg.add(url="https://github.com/SaguaroCapital/SaguaroTrader.jl/")
```

```julia
julia> ]  # enters the pkg interface
Pkg> add https://github.com/SaguaroCapital/SaguaroTrader.jl/
```

# Other Julia Backtesting Libraries

- [Bruno.jl](https://github.com/USU-Analytics-Solution-Center/Bruno.jl) - A modular, flexible package for simulating financial data, asset pricing, and trading strategy testing.
- [PingPong.jl](https://github.com/panifie/PingPong.jl) - Cryptocurrency trading bot, and backtesting framework.
- [Trading.jl](https://github.com/louisponet/Trading.jl) - A framework for defining and executing and backtesting trading strategies based on technical indicators.
