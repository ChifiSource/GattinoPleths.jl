module GattinoPleths
using Gattino
using Gattino.ToolipsSVG.ToolipsServables: htmlcomponent
__precompile__()
dir::String = @__DIR__
res::String = dir * "/../resources"

struct CloreplethResource
    uri::String
    names::Vector{String}
    dim::Pair{Int64, Int64}
end

const world_map = CloreplethResource(res * "/world.svg", ["mx", "us", "ca", "sd", "ss", "ge", "pe", "bf", "ly", "by", 
"pk", "id", "ye", "mg", "bo", "rs", "ci", "dz", "ch", "cm", "mk", "bw", "ke", "jo", 
"mx", "ae", "bz", "br", "sl", "ml", "cd", "it", "so", "af", "bd", "do", "gw", "gh", "at", "se", "tr", 
"ug", "mz", "jp", "nz", "cu", "ve", "pt", "co", "mr", "ao", "de", "th", "pg", "hr", 
"gl", "ne", "dk", "lv", "ro", "zm", "mm", "et", "gt", "sr"], 3000 => 3000)

function clorepleth(x::Vector{String}, y::Vector{<:Number}, rs::CloreplethResource, colors::Vector{String} = ["red", "pink"])
    maxy = maximum(y)
    pleth::Context = context(rs.dim[1], rs.dim[2]) do con::Context
        con.window[:children] = htmlcomponent(read(rs.uri, String), rs.names)
        allnames::Vector{String} = [begin
            comp[:text] = replace(comp[:text], "\"" => "'")
            comp.name::String
        end for comp in con.window[:children]]
        n::Integer = length(colors)
        nodata = filter(n -> ~(n in x), allnames)
        [begin
            current_y::Number = y[e]
            perc = Int64(round((current_y / maxy) * n))
            style!(con, value, "fill" => colors[perc])
        end for (e, value) in enumerate(x)]
        [begin 
            style!(con, value, "fill" => "gray")
        end for value in nodata]
    end
    pleth::Context
end

export clorepleth
end # module GattinoPleths
