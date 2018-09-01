__precompile__()
module HighestDensityRegions

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES

export hdr_thresholds


# utilities

"""
$(SIGNATURES)

Test if the given numbers are valid probabilities.
"""
is_valid_probabilities(αs) =  all(0 .≤ αs .≤ 1)

"""
$(SIGNATURES)

When `i == 0`, return `0` (with the element type of the vector), otherwise
behaves like `getindex`.
"""
@inline getindex_or_zero(x::AbstractVector{T}, i) where T =
    i == 0 ? zero(T) : x[i]

"""
$(SIGNATURES)

Find `i` in the sorted vector `xs` such that `xs[i-1] < α ≤ xs[i]`, with the
assumed extension ``xs[0] = 0``.

Return `γ, i` such that `interpolate_in(xs, γ, i) ≈ α`. See
[`interpolate_in`](@ref).
"""
function interpolation_coefficient_and_index(xs::Vector{T}, α) where {T <: Real}
    i = searchsortedfirst(xs, α)
    right = xs[i]
    left = getindex_or_zero(xs, i - 1)
    γ = (α - left) / (right - left)
    γ, i
end

"""
    $SIGNATURES

Calculate the linear interpolation `(1-γ)*xs[i-1] + γ*xs[i]`, with the assumed
extension ``xs[0] = 0``.
"""
function interpolate_in(xs, γ, i)
    left = getindex_or_zero(xs, i - 1)
    right = xs[i]
    (1 - γ) * left + γ * right
end

"""
$(SIGNATURES)

Return the thresholds for highest density regions with probability `αs`, given
the sorted densities and cumulative probabilities (using the same sorting order)
for each bin.
"""
function interpolated_density_thresholds(αs, sorted_densities, cumprobs)
    @argcheck is_valid_probabilities(αs)
    map(αs) do α
        γ, i = interpolation_coefficient_and_index(cumprobs, 1 - α)
        interpolate_in(sorted_densities, γ, i)
    end
end

"""
    $SIGNATURES

Cumulative probability.
"""
cumprob(x) = cumsum(x) |> x -> x ./ x[end]


# interface

"""
$(SIGNATURES)

Return thresholds for the highest density regions with coverage probabilities
`αs`.

`counts` is a vector proportional to count data for some bin structure, while
`densities` is a vector of corresponding densities. For each bin, it is assumed
that `counts[i] == densities[i] * bin_size[i]`, where `bin_size[i]` is the
measure of the bin.

A highest density region threshold `t` for a given `α` satisfies
`sum(counts[densities .> t]) ≈ α * sum(counts)`.

When bins have the same size, `counts` may be omitted and assumed to be
proportional to `densities`.
"""
function hdr_thresholds(αs, densities::AbstractVector, counts::AbstractVector)
    order = sortperm(densities)
    sorted_densities = densities[order]
    interpolated_density_thresholds(αs, sorted_densities, cumprob(counts[order]))
end

function hdr_thresholds(αs, densities)
    sorted_densities = sort(densities)
    interpolated_density_thresholds(αs, sorted_densities, cumprob(sorted_densities))
end

end # module
