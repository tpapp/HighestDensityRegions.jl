using HighestDensityRegions
using HighestDensityRegions:
    getindex_or_zero, interpolation_coefficient_and_index, interpolate_in
using Test

using Distributions
using DocStringExtensions

@testset "utilities" begin
    # getindex
    v = 1:3
    @test getindex_or_zero(v, 3) ≡ 3
    @test getindex_or_zero(v, 0) ≡ 0

    # interpolation index: arbitrary cumprobs
    c = [0.1, 0.4, 1.0]
    @test interpolation_coefficient_and_index(c, 0.1) == (1.0, 1)
    @test interpolation_coefficient_and_index(c, 0.2) == (1/3, 2)
    for _ in 1:20
        α = rand()
        γ, i = interpolation_coefficient_and_index(c, α)
        @test interpolate_in(c, γ, i) ≈ α
    end
    for (i, α) in enumerate(c)
        @test interpolation_coefficient_and_index(c, α) == (1.0, i)
    end

    # interpolation index: integer cumprobs
    N = 8
    cN = Vector((1:N) ./ N)
    for (i, α) in enumerate(cN)
        @test interpolation_coefficient_and_index(cN, α) == (1.0, i)
    end
end

"""
    $SIGNATURES

Calculate densities and counts using the cumulative density function for a
univariate distribution.
"""
function analytical_densities_and_counts(distribution, breaks)
    @assert issorted(breaks)
    counts = diff(cdf.(Ref(distribution), breaks))
    densities = counts ./ diff(breaks)
    densities, counts
end

"""
    $SIGNATURES

Calculate the empirical coverage probability of a (HDR) density threshold.
"""
coverage(threshold, densities, counts) =
    sum(counts[densities .≥ threshold]) / sum(counts)

"""
    $SIGNATURES

Test empirical coverage of HDR thresholds. `atol` is used for comparison, use
dense breaks for more precision.
"""
function test_coverage(αs, thresholds, densities, counts, atol = 0.01)
    for (i, α) in enumerate(αs)
        @test coverage(thresholds[i], densities, counts) ≈ α atol = atol
    end
end

@testset "normal thresholds with evenly spaced breaks" begin
    N = 1000
    breaks = range(-4; stop = 4, length = N)
    densities, counts =
        analytical_densities_and_counts(Normal(0, 1), breaks)
    αs = [0.25, 0.5, 0.75, 0.9]
    thresholds = hdr_thresholds(αs, densities, counts)
    test_coverage(αs, thresholds, densities, counts)
    thresholds_even = hdr_thresholds(αs, densities)
    @test thresholds_even ≈ thresholds
end

@testset "gamma thresholds with log breaks" begin
    breaks = exp.(range(0; stop = 2, length = 1000)) .- 1
    densities, counts = analytical_densities_and_counts(Gamma(1, 1), breaks)
    αs = [0.25, 0.5, 0.75, 0.9]
    thresholds = hdr_thresholds(αs, densities, counts)
    test_coverage(αs, thresholds, densities, counts)
end
