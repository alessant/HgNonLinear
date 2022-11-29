function build_hg(path)
    df = CSV.read(path, DataFrame; delim="],", header=0)

    nodes = Dict{Int,Int}()
    nodes_per_edge = Dict{Int,Vector{Int}}()

    hg = Hypergraph(0,0)

    for he in eachcol(df)
        #remove characters [] from string
        #println(he[:1])
        d = split(he[:1], ",")
        vs = map(x -> parse(Int,(strip(replace(x, r"\[|\]" => "")))), d)
        
        #println(vs)
        
        # add v if it not exist
        for v in vs
            if !haskey(nodes, v)
                v_id = add_vertex!(hg)
                push!(nodes, v=>v_id)
            end
        end

        # add he 
        vertices = Dict{Int, Bool}(nodes[v] => true for v in vs)
        he_id = add_hyperedge!(hg; vertices = vertices)
        push!(nodes_per_edge, he_id => vs)
    end

    return hg, nodes, nodes_per_edge
end

