# HighestDensityRegions

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![Build Status](https://travis-ci.org/tpapp/HighestDensityRegions.jl.svg?branch=master)](https://travis-ci.org/tpapp/HighestDensityRegions.jl)
[![Coverage Status](https://coveralls.io/repos/tpapp/HighestDensityRegions.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/HighestDensityRegions.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/HighestDensityRegions.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/HighestDensityRegions.jl?branch=master)

Julia library for calculating Highest Density Regions.

## Installation

The package is not (yet) registered. Install with

```julia
pkg> add https://github.com/tpapp/HighestDensityRegions.jl
```

## Usage

The single exported function is `hdr_thresholds`, which returns a vector thresholds for the given probabilities.

## Bibliography

- Hyndman, R. J. (1996). Computing and graphing highest density regions. The American Statistician, 50(2), 120–126.
