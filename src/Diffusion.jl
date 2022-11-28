using HgNonLinear
using SimpleHypergraphs
using Random
using Statistics
using Distributions

function s_one(x)
    lambda = -1
    if x <= 0.4
        ℯ^(lambda * x)
    elseif x >= 0.80
        - ℯ^(lambda * x)
    else
        0.0
    end
    
end

function s_two(x)
    delta = -5
    ℯ^(delta * x)
end

vsize = 500
esize = 30
max_iter = 500
#h = random_kuniform_model(vsize,esize,5)
h = random_preferential_model(vsize,0.7)
esize = nhe(h)
#rng = MersenneTwister(1234)
# rand!(zeros(vsize))
opinions =  vcat(rand(Uniform(0.0,0.5), Int(vsize/2)), rand(Uniform(0.5,1.0), Int(vsize/2)))
original_opinions = deepcopy(opinions)
iter_opinions = deepcopy(opinions)
#
for i in 1:max_iter
    println("$i/$max_iter")
    for v in 1:nhv(h)
        #compute the new opinion of v
        gain = 0.0
        for e in 1:nhe(h)
            avg = 0.0
            avg_others = 0.0
            vertices = getvertices(h,e)
            for u in vertices
                avg = avg + opinions[u.first]
                if !(u.first == v) 
                    avg_others = avg_others + opinions[u.first]
                end
            end
           # println("$avg / $length(vertices) = $(avg / length(vertices))")
           # println("others $avg_others / $length(vertices) = $(avg_others / length(vertices)-1)")
            avg = avg / length(vertices)
            avg_others = avg_others / length(vertices) - 1
    
            s1 = s_one(abs(avg - opinions[v]))
            s2 = 0.0
            for u in vertices
                tmp = s_two(abs(avg_others - opinions[u.first])) * (opinions[u.first] - opinions[v])
                s2 = s2 + tmp
            end
            #println("s1 $s1 s2 $s2")
            gain = gain + (s1 * s2)
        end
        iter_opinions = deepcopy(opinions)
        opinions[v] = (opinions[v] + gain) < 0.0 ? 0.0 : (opinions[v] + gain) > 1.0 ? 1.0 : opinions[v] + gain
        
    end
    if std(opinions .- iter_opinions) < 0.0005
        println("Converged to std < 0.0005 at $i/$max_iter iteration")
        break
    end
end

println(original_opinions,"\n->\n",opinions)