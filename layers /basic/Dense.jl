module Neural
using Flux 

struct neural 
    W
    b
end 

neural(in::Integer, out::Integer) =
  neural(randn(out, in)*0.1, randn(out)*0.1)

(m::neural)(x)=m.W*x.+m.b

export neural


end 