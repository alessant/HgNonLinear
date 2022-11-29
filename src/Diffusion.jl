using HgNonLinear
using SimpleHypergraphs
using Random
using Statistics
using Distributions
using PyPlot

path = "data/sfhh.data"
hg, nodes_id_mapping, nodes_per_edge = build_hg(path)
size(hg)

function s_one(x)
    lambda = -1
    return ℯ^(lambda * x)
    if x <= 0.1#0.20#0.4#
        ℯ^(lambda * x)
    elseif x >= 0.15#0.6#0.80#
        - ℯ^(lambda * x)
    else
        0.0
    end
    
end

function s_two(x)
    delta = -5
    ℯ^(delta * x)
end

vsize = 10
esize = 5
max_iter = 500
#h = random_kuniform_model(vsize,esize,5)
h = random_preferential_model(vsize,0.4)
h = hg
esize = nhe(h)
#rng = MersenneTwister(1234)
# rand!(zeros(vsize))
opinions =  vcat(
    rand(Uniform(0.0,0.5), Int(floor(nhv(h)/2))), 
    rand(Uniform(0.5,1.0), Int(ceil(nhv(h)/2)))
    )

opinions = vcat(
        zeros(Int(floor(nhv(h)/2))), 
        zeros(Int(ceil(nhv(h)/2)))
    ) 

v_dist = [(v, length(gethyperedges(h, v))) for v in 1:nhv(h)]
clf()
hist(v_dist)
gcf()

he_dist = [(he, length(getvertices(h, he))) for he in 1:nhe(h)]
max_he = sort!(he_dist, by= x->x[2], rev=true)

for v in getvertices(h, max_he[1][1])
    opinions[v.first] = 1
end

sum(opinions)


original_opinions = deepcopy(opinions)
iter_opinions = deepcopy(opinions)

opinion_history = Dict{Int, Array{Float64, 1}}()
opinion_history_test = Dict{Int, Array{Float64, 1}}()

for v in 1:nhv(h)
    push!(
        get!(opinion_history, v, Array{Float64, 1}()),
        opinions[v]
    )
end

for i in 1:max_iter
    println("$i/$max_iter")
    for v in 1:nhv(h)
        #compute the new opinion of v
        push!(
            get!(opinion_history_test, v, Array{Float64, 1}()),
            opinions[v]
        )

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

            push!(
            get!(opinion_history_test, v, Array{Float64, 1}()),
            #opinions[v] + (s1 * s2)
            (s1 * s2)
        )
        end
        #iter_opinions = deepcopy(opinions)
        iter_opinions[v] = (gain) < 0.0 ? 0.0 : (gain) > 1.0 ? 1.0 : gain
        # opinions[v] = (opinions[v] + gain) < 0.0 ? 0.0 : (opinions[v] + gain) > 1.0 ? 1.0 : opinions[v] + gain 

        push!(
            get!(opinion_history, v, Array{Float64, 1}()),
            iter_opinions[v]
        )
    end

    if std(opinions .- iter_opinions) < 0.0005
        println("Converged to std < 0.0005 at $i/$max_iter iteration")
        opinions = deepcopy(iter_opinions)
        break
    end

    opinions = deepcopy(iter_opinions)
end

#opinions[v] = (opinions[v] + gain) < 0.0 ? 0.0 : (opinions[v] + gain) > 1.0 ? 1.0 : opinions[v] + gain
println(original_opinions,"\n->\n",opinions)

clf()

opinions_to_plot = deepcopy(opinion_history)

opinion_history

for v in keys(opinion_history)
    plot(collect(range(1, length(opinion_history[v]))), opinion_history[v], color="black", linewidth=.5)
    
    for op in enumerate(opinion_history[v])
        op[1] == 1 && continue

        if op[2] > 0 && op[2] < 1
            println("$v -- $(op[2])")
        end
    end
end

ylim(top=1, bottom=0)

gcf()
opinions


clf()
opinions_to_plot = deepcopy(opinion_history_test)

for v in keys(opinion_history_test)
    plot(collect(range(1, length(opinion_history_test[v]))), opinion_history_test[v], color="black")
    
    for op in enumerate(opinion_history_test[v])
        op[1] == 1 && continue

        # if op[2] > 0 && op[2] < 1
        #     println("$v -- $(op[2])")
        # end
    end
end

ylim(top=1, bottom=0)

gcf()