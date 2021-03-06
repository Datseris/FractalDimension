module FractalDimension

using DrWatson
using Reexport
@reexport using DynamicalSystems, PyPlot, Statistics

include("fractal_dim_fit.jl")

include("data_generation.jl")
export Data
include("make_C_H.jl")

function mse(x, y)
    m = length(x)
    @assert m == length(y)
    @inbounds mse = sum(abs2(x[i] - y[i]) for i in 1:m) / m
    return mse
end
using Statistics: mean
rmse(x, y) = sqrt(mse(x, y))
export rmse

include("style.jl") # this doesn't work with `@quickactivate` for some reason
include("mainplot.jl")

end
