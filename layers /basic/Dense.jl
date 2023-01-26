module Neural
using Flux 

struct neural 
    W
    b
end 

function neural((in,out)::Pair;bias= true, init=Flux.rand32)
    W=init(out,in)
    b=Flux.create_bias(W,bias,out)
    neural(W,b)
end 

(m::neural)(x)=m.W*x.+m.b

export neural


end 