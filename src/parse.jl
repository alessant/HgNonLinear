
function load_hg(filename)
    data = readstring(filename)
    data = split(data, ",")
    nodes = Dict{Int,Int}()
    edges = Dict{Int,Int}()
    mapedges = Dict{Int,Vector{Int}}()
    index_v = 1
    index_e = 1
    for d in data
        #remove characters [] from string
        d = replace(d, r"\[|\]" => "")
        d = split(d, ",")
        push!(nodes, index_v => parse(Int, d[1]))
        

    end

end