using DrWatson
@quickactivate :FractalDimension # uses DynamicalSystems, PyPlot
include(srcdir("style.jl"))

N = 1*10^5

ds = range(2; step = 1, length = 6)

qH = 1
qC = 2

Cmethod = "standard" # bueno or standard. Decides the ε range.

systems = fill(:roessler_chaotic, 3)
append!(systems, fill(:roessler_dynamic, 2))
push!(systems, :roessler_rounded)
# imo a 10% dynamic noise would correspond to a η≈2 for Rössler,
# as the regularisation happens afterwards
parameters = ["η" => x for x in [0, 0.05, 0.1, 1, 2, 0]]
Cmethod = "standard" # bueno or standard. Decides εmax for correlation sum.

# Calculate values for H, C
eHs, eCs, Hs, Cs = [Vector{Float64}[] for i in 1:4]
for i in 1:length(systems)
    data = systems[i]
    params = @strdict N qH qC data
    if Cmethod ≠ "standard"
        params["Cmethod"] = Cmethod
    end
    push!(params, parameters[i])
    params["z"] = -1

    # Uncomment these lines to plot attractors
    # params["Δt"] = 0.1
    # data_producing_function = getfield(Data, data)
    # X = data_producing_function(; dict2ntuple(params)...)
    # figure()
    # plot3D(columns(X)...; lw = 1, alpha = 0.25)
    # scatter3D(columns(X)...; alpha = 0.25)
    # title(labels[i])

    # This is the main call that calculates everything
    output, s = produce_or_load(
        datadir("main"), params, make_C_H;
        prefix = string(data), suffix = "jld2", force = false,
        ignores = ["data"], storepatch = false,
    )
    @unpack eH, eC, H, C = output
    push!(eHs, eH); push!(Hs, H); push!(eCs, eC); push!(Cs, C)
end

# Do the actual plot
labels = ["none", "5% additive", "10% additive", "5% dynamic", "10% dynamic", "rounding"]
legendtitle = "noise"

fig, axs = mainplot(
    Hs, Cs, eHs, eCs, labels, legendtitle; 
    qH, qC, tol = 0.25, 
    # offsets = range(0; length = 6, step = 2),
    # dimension_fit_C = FractalDimension.logarithmic_corrected_fit_lsqfit,
    dimension_fit_C = FractalDimension.linear_regression_fit_glm,
)


# Find bueno-orovio distance for highlighting where things break down,
# and we would miss the stuff.

data = systems[5]
data_producing_function = getfield(Data, data)
X = data_producing_function(; N)
P = autoprismdim(X)
r0 = ChaosTools.estimate_r0_buenoorovio(X, P)[1]

axs[2].axvline(log(r0); color = "C0", lw = 2, ls = ":")

if Cmethod == "standard"
wsave(plotsdir("paper", "noise"), fig)
else
wsave(plotsdir("paper", "noise_$(Cmethod)"), fig)
end