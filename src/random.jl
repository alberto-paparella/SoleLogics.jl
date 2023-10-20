using Random
using StatsBase

import Random: rand
import StatsBase: sample

#= ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Formulas ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ =#

# WIP by Mauro
# TODO: add these new methods for rand formula generation
# rand(connectives, atom leaves array, algebra from which infer truth values)
# rand(connectives, atom leaves array, truth values with common supertype)
# rand(connectives, atom leaves array, true/false (use truth values as leaf or not. If true, default to boolean))
# sample(..., probability distribution)

"""
    Base.rand(
        [rng::AbstractRNG = Random.GLOBAL_RNG, ]
        alphabet,
        args...;
        kwargs...
    )::Atom

Randomly sample an atom from an `alphabet`, according to a uniform distribution.

# Implementation
If the `alphabet` is finite, the function defaults to `rand(rng, atoms(alphabet))`;
otherwise, it must be implemented, and additional keyword arguments should be provided
in order to limit the (otherwise infinite) sampling domain.

See also
[`isfinite`](@ref),
[`AbstractAlphabet'](@ref).
"""
function Base.rand(alphabet::AbstractAlphabet, args...; kwargs...)
    Base.rand(Random.GLOBAL_RNG, alphabet, args...; kwargs...)
end

function Base.rand(
    rng::AbstractRNG,
    atoms::AbstractVector{<:Atom},
    args...;
    kwargs...
)
    # EMPTY - This could be the fallback of the following dispatch
end

function Base.rand(
    rng::AbstractRNG,
    alphabet::AbstractAlphabet,
    args...;
    kwargs...
)
    if isfinite(alphabet)
        Base.rand(rng, atoms(alphabet), args...; kwargs...)
    else
        error("Please, provide method Base.rand(rng::AbstractRNG, " *
            "alphabet::$(typeof(alphabet)), args...; kwargs...).")
    end
end


# For the case of a CompleteFlatGrammar, the alphabet and the operators suffice.
function Base.rand(
    height::Integer,
    g::CompleteFlatGrammar,
    args...
)
    Base.rand(Random.GLOBAL_RNG, height, g, args...)
end

function Base.rand(
    rng::AbstractRNG,
    height::Integer,
    g::CompleteFlatGrammar,
    args...;
    kwargs...
)
    randbaseformula(height, alphabet(g), operators(g), args...; rng=rng, kwargs...)
end

function rand(
    height::Integer,    # By Mauro - to generate a random formula, height has to be known
    connectives::Vector{Connective},
    leaves::Vector{AbstractLeaf},
    algebra::AbstractAlgebra,
    args...;
    rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
    kwargs...
)
    [push!(leaves, t()) for t in algebra |> truthtype |> subtypes]
    randformula(height, leaves, connectives, args...; rng=rng, kwargs...)
end

function rand(
    height::Integer,    # By Mauro - to generate a random formula, height has to be known
    connectives::Vector{Connective},
    leaves::Vector{AbstractLeaf},
    truthvals::Vector{Truth},
    args...;
    rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
    kwargs...
)
    @assert supertype.(typeof.(truthvals)) |> unique |> length == 1
        "truthvals $(truthvals) must have a common supertype."

    randformula(height, vcat(leaves, truthvals), connectives, args...; rng=rng, kwargs...)
end

# Set truthatleaves flag to false to avoid placing truth values at leaves.
function rand(
    height::Integer,    # By Mauro - to generate a random formula, height has to be known
    connectives::Vector{Connective},
    leaves::Vector{AbstractLeaf};
    truthatleaves::Boolean = true,
    truthtype::Type,
    args...;
    rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
    kwargs...
)
    if (truthatleaves)
        [push!(leaves, t()) for t in truthtype |> subtypes]
    end

    randformula(height, leaves, connectives, args...; rng=rng, kwargs...)
end

function StatsBase.sample(
    alphabet::AbstractAlphabet,
    weights::AbstractWeights,
    args...;
    kwargs...
)
    StatsBase.sample(Random.GLOBAL_RNG, alphabet, weights, args...; kwargs...)
end

function StatsBase.sample(
    rng::AbstractRNG,
    alphabet::AbstractAlphabet,
    weights::AbstractWeights,
    args...;
    kwargs...
)
    if isfinite(alphabet)
        StatsBase.sample(rng, atoms(alphabet), weights, args...; kwargs...)
    else
        error("Please, provide method StatsBase.sample(rng::AbstractRNG, " *
            "alphabet::$(typeof(alphabet)), args...; kwargs...).")
    end
end

function StatsBase.sample(l::AbstractLogic, weights::AbstractWeights, args...; kwargs...)
    StatsBase.sample(Random.GLOBAL_RNG, l, weights, args...; kwargs...)
end

function StatsBase.sample(
    rng::AbstractRNG,
    l::AbstractLogic,
    weights::AbstractWeights,
    args...;
    kwargs...
)
    StatsBase.sample(rng, grammar(l), weights, args...; kwargs...)
end

"""
    StatsBase.sample(
        [rng::AbstractRNG = Random.GLOBAL_RNG, ]
        g::AbstractGrammar,
        height::Integer,
        args...;
        kwargs...
    )::Formula

Randomly sample a logic formula of given `height` from a grammar `g`.

# Implementation
This method for must be implemented, and additional keyword arguments should be provided
in order to limit the (otherwise infinite) sampling domain.

See also
[`AbstractAlphabet'](@ref).
"""
function StatsBase.sample(
    rng::AbstractRNG,
    height::Integer,
    g::AbstractGrammar,
    weights::AbstractWeights,
    args...;
    kwargs...
)
    randbaseformula(
        height, alphabet(g), operators(g);
        rng=rng, picker=StatsBase.sample, weights=weights, args..., kwargs...)
end

function StatsBase.sample(
    height::Integer,
    g::AbstractGrammar,
    weights::AbstractWeights,
    args...;
    kwargs...
)
    StatsBase.sample(Random.GLOBAL_RNG, height, g, weights, args...; kwargs...)
end

#= ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CompleteFlatGrammar ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ =#

# TODO
# - make rng first (optional) argument of randformula (see above)
# - in randformula, keyword argument alphabet_sample_kwargs that are unpacked upon sampling atoms, as in: Base.rand(rng, a; alphabet_sample_kwargs...). This would allow to sample from infinite alphabets, so when this parameter, !isfinite(alphabet) is allowed!
# - Decide whether to keep randformula or randbaseformula

doc_randformula = """
    randformula(
        height::Integer,
        alphabet,
        operators::Vector{<:Operator};
        rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG
    )::SyntaxTree

    # TODO @Mauro implement this method.
    function randbaseformula(
        height::Integer,
        g::AbstractGrammar;
        rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG
    )::SyntaxTree

Return a pseudo-randomic `SyntaxTree`.

# Arguments
- `height::Integer`: height of the generated structure;
- `alphabet::AbstractAlphabet`: collection from which atoms are chosen randomly;
- `operators::Vector{<:Operator}`: vector from which legal operators are chosen;
- `g::AbstractGrammar`: alternative to passing alphabet and operators separately. (TODO explain?)

# Keyword Arguments
- `rng::Union{Intger,AbstractRNG} = Random.GLOBAL_RNG`: random number generator;
- `picker::Function` = method used to pick a random element. For example, this could be
    Base.rand or StatsBase.sample.
- `weights::AbstractWeights` = weights vector of StatsBase, needed if `picker` function is
    StatsBase.sample.

# Examples

```julia-repl
julia> syntaxstring(randformula(4, ExplicitAlphabet([1,2]), [NEGATION, CONJUNCTION, IMPLICATION]))
"¬((¬(¬(2))) → ((1 → 2) → (1 → 2)))"
```

See also [`AbstractAlphabet`](@ref), [`SyntaxTree`](@ref).
"""

"""$(doc_randformula)"""
function randformula(
    height::Integer,
    alphabet,
    operators::Vector{<:Operator};
    modaldepth::Integer = height,
    rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
    picker::Function = rand,
    opweights::Union{AbstractWeights,AbstractVector{<:Real},Nothing} = nothing
)::SyntaxTree
    alphabet = convert(AbstractAlphabet, alphabet)
    initrng(rng)

    @assert isnothing(opweights) ||
        length(opweights) == length(operators) "Mismatching numbers of operators " *
            "($(length(operators))) and opweights ($(length(opweights)))."

    if (isnothing(opweights))
        opweights = StatsBase.uweights(length(operators))
    elseif (opweights isa AbstractVector)
        opweights = StatsBase.weights(opweights)
    end

    nonmodal_operators = findall(!ismodal, operators)

    function _randformula(
        rng::AbstractRNG,
        height::Integer,
        modaldepth::Integer
    )::SyntaxTree
        if height == 0
            # Sample atom from alphabet
            return SyntaxTree(picker(rng, atoms(alphabet)))
        else
            # Sample operator and generate children (modal operators only if modaldepth > 0)
            ops, ops_w = begin
                if modaldepth > 0
                    operators, opweights
                else
                    operators[nonmodal_operators], opweights[nonmodal_operators]
                end
            end

            # op = rand(rng, ops)
            op = sample(rng, ops, ops_w)
            ch = Tuple([
                    _randformula(rng, height-1, modaldepth-(ismodal(op) ? 1 : 0))
                    for _ in 1:arity(op)])
            return SyntaxTree(op, ch)
        end
    end

    # If the alphabet is not iterable, this function should not work.
    if !isfinite(alphabet)
        @warn "Attempting to generate random formulas from " *
            "(infinite) alphabet of type $(typeof(alphabet))!"
    end

    return _randformula(rng, height, modaldepth)
end

height, alphabet(g), operators(g);
rng=rng, picker=StatsBase.sample, weights=weights, args..., kwargs...)

function randbaseformula(
    height::Integer,
    alphabet::AbstractAlphabet,
    operators::Vector{<:Operator},
    args...;
    rng::AbstractRNG = Random.GLOBAL_RNG,
    picker = rand,
    weights = Union{AbstractWeights, Nothing}
    kwargs...
)::SyntaxTree
    error("TODO: implement this")
end

function randbaseformula(
    height::Integer,
    g::AbstractGrammar,
    args...;
    rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
    kwargs...
)::SyntaxTree
    randbaseformula(height, alphabet(g), operator(g), args...; rng=rng, kwargs...)
end

#= ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Kripke Structures ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ =#

# function fanfan()
# end

# function _fanout()
# end

# function _fanin()
# end

# function dispense_alphabet()
# end

# function sample_worlds()
# end

# function generate_kripke_frame(
#     n::Integer
# )
#     # ws = WorldSet{AbstractWorld}([SoleLogics.World(i) for i in 1:n])
# end

# #= Deprecated overlay code

# https://hal.archives-ouvertes.fr/hal-00471255v2/document

# # Fan-in/Fan-out method
# # Create a graph with n nodes as an adjacency list and return it.
# # It's possible to set a global maximum to input_degree and output_degree.
# # Also it's possible to choose how likely a certain "phase" will happen
# # 1) _fanout increases a certain node's output_degree grow by spawning new vertices
# # 2) _fanin increases the input_degree of a certain group of nodes
# #    by linking a single new vertices to all of them
# function fanfan(
#     n::Integer,
#     id::Integer,
#     od::Integer;
#     threshold::Float64 = 0.5,
#     rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
# )
#     rng = (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)
#     adjs = Adjacents{PointWorld}()
#     setindex!(adjs, Worlds{PointWorld}([]), PointWorld(0))  # Ecco qua ad esempio metti un GenericWorld

#     od_queue = PriorityQueue{PointWorld,Int64}(PointWorld(0) => 0)

#     while length(adjs.adjacents) <= n
#         if rand(rng) <= threshold
#             _fanout(adjs, od_queue, od, rng)
#         else
#             _fanin(adjs, od_queue, id, od, rng)
#         end
#     end

#     return adjs
# end

# function _fanout(
#     adjs::Adjacents{PointWorld},
#     od_queue::PriorityQueue{PointWorld,Int},
#     od::Integer,
#     rng::AbstractRNG,
# )
#
#     # Find the vertex v with the biggest difference between its out-degree and od.
#     # Create a random number of vertices between 1 and (od-m)
#     # and add edges from v to these new vertices.
#
#     v, m = peek(od_queue)

#     for i in rand(rng, 1:(od-m))
#         new_node = PointWorld(length(adjs))
#         setindex!(adjs, Worlds{PointWorld}([]), new_node)
#         push!(adjs, v, new_node)

#         od_queue[new_node] = 0
#         od_queue[v] = od_queue[v] + 1
#     end
# end

# function _fanin(
#     adjs::Adjacents{PointWorld},
#     od_queue::PriorityQueue{PointWorld,Int},
#     id::Integer,
#     od::Integer,
#     rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
# )
#     rng = (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)
#     #=
#     Find the set S of all vertices that have out-degree < od.
#     Compute a subset T of S of size at most id.
#     Add a new vertex v and add new edges (v, t) for all t ∈ T
#     =#
#     S = filter(x -> x[2] < od, od_queue)
#     T = Set(sample(collect(S), rand(rng, 1:min(id, length(S))), replace = false))

#     v = PointWorld(length(adjs))
#     for t in T
#         setindex!(adjs, Worlds{PointWorld}([]), v)
#         push!(adjs, t[1], v)

#         od_queue[t[1]] = od_queue[t[1]] + 1
#         od_queue[v] = 0
#     end
# end

# # Associate each world to a subset of proposistional letters
# function dispense_alphabet(
#     ws::Worlds{T};
#     P::LetterAlphabet = SoleLogics.alphabet(MODAL_LOGIC),
#     rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
# ) where {T<:AbstractWorld}
#     rng = (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)
#     evals = Dict{T,LetterAlphabet}()
#     for w in ws
#         evals[w] = sample(P, rand(rng, 0:length(P)), replace = false)
#     end
#     return evals
# end

# # NOTE: read the other gen_kmodel dispatch below as it's signature is more flexible.
# # Generate and return a Kripke structure.
# # This utility uses `fanfan` and `dispense_alphabet` default methods
# # to define `adjacents` and `evaluations` but one could create its model
# # piece by piece and then calling KripkeStructure constructor.
# function gen_kmodel(
#     n::Integer,
#     in_degree::Integer,   # needed by fanfan
#     out_degree::Integer;  # needed by fanfan
#     P::LetterAlphabet = SoleLogics.alphabet(MODAL_LOGIC),
#     threshold = 0.5,      # needed by fanfan
#     rng::Union{Integer,AbstractRNG} = Random.GLOBAL_RNG,
# )
#     rng = (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)
#     ws = Worlds{PointWorld}(world_gen(n))
#     adjs = fanfan(n, in_degree, out_degree, threshold = threshold, rng = rng)
#     evs = dispense_alphabet(ws, P = P, rng = rng)
#     return KripkeStructure{PointWorld}(ws, adjs, evs)
# end

# # Generate and return a Kripke structure.
# # Example of valid calls:
# # gen_kmodel(15, MODAL_LOGIC, :erdos_renyi, 0.42)
# # gen_kmodel(10, MODAL_LOGIC, :fanin_fanout, 3, 4)
# #
# # NOTE:
# # This function is a bit tricky as in kwargs (that is, the arguments of the selected method)
# # n has to be excluded (in fact it is already the first argument)
# # In other words this dispatch is not compatible with graph-generation functions whose
# # signature differs from fx(n, other_arguments...)
# function gen_kmodel(n::Integer, P::LetterAlphabet, method::Symbol, kwargs...)
#     if method == :fanin_fanout
#         fx = fanfan
#     elseif method == :erdos_renyi
#         fx = gnp
#     else
#         error("Invalid method provided: $method. Refer to the docs <add link here>")
#     end

#     ws = Worlds{PointWorld}(world_gen(n))
#     adjs = fx(n, kwargs...)
#     evs = dispense_alphabet(ws, P = P)
#     return KripkeStructure{PointWorld}(ws, adjs, evs)
# end

# =#
