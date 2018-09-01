# call line below once to install
# using Pkg; pkg"add PGFPlotsX"; pkg"add KernelDensity"; pkg"add Distributions"

using PGFPlotsX, KernelDensity, HighestDensityRegions, Distributions

d = MixtureModel([Normal(-1, 1), Normal(1, 0.2)], [0.6, 0.4])
x = rand(d, 2000)
k = kde(x)
xgrid = range(minimum(x); stop = maximum(x), length = 1000)
ygrid = pdf.(Ref(k), xgrid)
threshold = first(hdr_thresholds([0.5], ygrid))

p = @pgf Axis({ xlabel = "x", ylabel = "kernel density", width = "10cm", height = "8cm" },
              Plot({ very_thick, mesh, point_meta = "explicit" , shader = "interp"},
                   Coordinates(xgrid, ygrid; meta = Int.(threshold .< ygrid))))
pgfsave("1d-density.svg", p)
