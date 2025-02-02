# This file is a part of Julia. License is MIT: https://julialang.org/license

"""
Support for sparse arrays. Provides `AbstractSparseArray` and subtypes.
"""
module SparseArrays

using Base: ReshapedArray, promote_op, setindex_shape_check, to_shape, tail,
    require_one_based_indexing, promote_eltype
using Base.Sort: Forward
using LinearAlgebra
using LinearAlgebra: AdjOrTrans, matprod



import Base: +, -, *, \, /, &, |, xor, ==, zero
import LinearAlgebra: mul!, ldiv!, rdiv!, cholesky, adjoint!, diag, eigen, dot,
    issymmetric, istril, istriu, lu, tr, transpose!, tril!, triu!, isbanded,
    cond, diagm, factorize, ishermitian, norm, opnorm, lmul!, rmul!, tril, triu

import Base: adjoint, argmin, argmax, Array, broadcast, circshift!, complex, Complex,
    conj, conj!, convert, copy, copy!, copyto!, count, diff, findall, findmax, findmin,
    float, getindex, imag, inv, kron, kron!, length, map, maximum, minimum, permute!, real,
    rot180, rotl90, rotr90, setindex!, show, similar, size, sum, transpose,
    vcat, hcat, hvcat, cat, vec

using Random: default_rng, AbstractRNG, randsubseq, randsubseq!

export AbstractSparseArray, AbstractSparseMatrix, AbstractSparseVector,
    SparseMatrixCSC, SparseVector, blockdiag, droptol!, dropzeros!, dropzeros,
    issparse, nonzeros, nzrange, rowvals, sparse, sparsevec, spdiagm,
    sprand, sprandn, spzeros, nnz, permute, findnz,  fkeep!, ftranspose!,
    sparse_hcat, sparse_vcat, sparse_hvcat

# helper function needed in sparsematrix, sparsevector and higherorderfns
@inline _iszero(x) = x == 0
@inline _iszero(x::Number) = Base.iszero(x)
@inline _iszero(x::AbstractArray) = Base.iszero(x)
@inline _isnotzero(x) = (x != 0) !== false # like `x != 0`, but handles `x::Missing`
@inline _isnotzero(x::Number) = !iszero(x)
@inline _isnotzero(x::AbstractArray) = !iszero(x)

include("abstractsparse.jl")
include("sparsematrix.jl")
include("sparseconvert.jl")
include("sparsevector.jl")
include("higherorderfns.jl")
include("linalg.jl")
include("deprecated.jl")

## Functions to switch to 0-based indexing to call external sparse solvers

# Convert from 1-based to 0-based indices
function decrement!(A::AbstractArray{T}) where T<:Integer
    for i in eachindex(A); A[i] -= oneunit(T) end
    A
end
decrement(A::AbstractArray{<:Integer}) = decrement!(copy(A))

# Convert from 0-based to 1-based indices
function increment!(A::AbstractArray{T}) where T<:Integer
    for i in eachindex(A); A[i] += oneunit(T) end
    A
end
increment(A::AbstractArray{<:Integer}) = increment!(copy(A))

include("solvers/LibSuiteSparse.jl")
using .LibSuiteSparse

if Base.USE_GPL_LIBS
    include("solvers/umfpack.jl")
    include("solvers/cholmod.jl")
    include("solvers/spqr.jl")
end

zero(a::AbstractSparseArray) = spzeros(eltype(a), size(a)...)

LinearAlgebra.diagzero(D::Diagonal{<:AbstractSparseMatrix{T}},i,j) where {T} =
    spzeros(T, size(D.diag[i], 1), size(D.diag[j], 2))

end
