module Stack_Up




struct Chain{T<:Union{Tuple, NamedTuple, AbstractVector}}
  layers::T
end

Chain(xs...) = Chain(xs)
function Chain(; kw...)
  :layers in keys(kw) && throw(ArgumentError("a Chain cannot have a named layer called `layers`"))
  isempty(kw) && return Chain(())
  Chain(values(kw))
end

using Lazy
@forward Chain.layers Base.getindex, Base.length, Base.first, Base.last,
  Base.iterate, Base.lastindex, Base.keys, Base.firstindex
using Functors
@functor Chain

(c::Chain)(x) = _applychain(c.layers, x)

@generated function _applychain(layers::Tuple{Vararg{<:Any,N}}, x) where {N}
  symbols = vcat(:x, [gensym() for _ in 1:N])
  calls = [:($(symbols[i+1]) = layers[$i]($(symbols[i]))) for i in 1:N]
  Expr(:block, calls...)
end

_applychain(layers::NamedTuple, x) = _applychain(Tuple(layers), x)

function _applychain(layers::AbstractVector, x)  # type-unstable path, helps compile times
  for f in layers
    x = f(x)
  end
  x
end

Base.getindex(c::Chain, i::AbstractArray) = Chain(c.layers[i])
Base.getindex(c::Chain{<:NamedTuple}, i::AbstractArray) =
  Chain(NamedTuple{keys(c)[i]}(Tuple(c.layers)[i]))
function Base.show(io::IO, c::Chain)
  print(io, "Chain(")
  _show_layers(io, c.layers)
  print(io, ")")
end

_show_layers(io, layers::Tuple) = join(io, layers, ", ")
_show_layers(io, layers::NamedTuple) = join(io, ["$k = $v" for (k, v) in pairs(layers)], ", ")
_show_layers(io, layers::AbstractVector) = (print(io, "["); join(io, layers, ", "); print(io, "]"))


export Chain

end 