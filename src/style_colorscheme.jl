struct CyclicContainer <: AbstractVector{String}
    c::Vector{String}
    n::Int
end
CyclicContainer(c) = CyclicContainer(c, 0)

Base.length(c::CyclicContainer) = typemax(Int)
Base.size(c::CyclicContainer) = size(c.c)
Base.getindex(c::CyclicContainer, i) = c.c[(i-1)%length(c.c) + 1]
function Base.getindex(c::CyclicContainer)
    c.n += 1
    c[c.n]
end
Base.iterate(c::CyclicContainer, i = 1) = iterate(c.c, i)

COLORSCHEME = [
    "#6D44D0",
    "#2CB3BF",
    "#1B1B1B",
    "#DA5210",
    "#03502A",
    "#866373",
]

COLORS = CyclicContainer(COLORSCHEME)
# LINESTYLES = CyclicContainer(["-", "--", ":", "-."])
LINESTYLES = CyclicContainer(["-", "--", "-."])
MARKERS = CyclicContainer(["o", "v", "s", "p", "X"])
