# call line below once to install
# using Pkg; pkg"add PGFPlotsX"; pkg"add KernelDensity"; pkg"add Distributions"

using PGFPlotsX, KernelDensity, HighestDensityRegions, Distributions, Contour, LinearAlgebra

d = MixtureModel([MultivariateNormal([-1, -1], Diagonal([0.5, 0.5])),
                  MultivariateNormal([1, 1], Diagonal([0.7, 1.5]))], [0.6, 0.4])
x = rand(d, 2000)
x1, x2 = x[1, :], x[2, :]
k = kde((x1, x2))
ik = InterpKDE(k)
ps = pdf.(Ref(ik), x1, x2)
qs = 0.05:0.1:0.95
thresholds = hdr_thresholds(qs, ps)

xgrid = range(minimum(x); stop = maximum(x), length = 100)
pgrid = pdf.(Ref(ik), xgrid, xgrid')

p = @pgf Axis({ xlabel = raw"$x_1$", ylabel = raw"$x_2$", width = "10cm", height = "10cm" },
              Plot({ thick }, Table(contours(xgrid, xgrid, pgrid, thresholds))))
pgfsave("2d-density.svg", p)
