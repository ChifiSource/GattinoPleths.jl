module GattinoPleths
using Gattino
using Gattino.ToolipsSVG.ToolipsServables: AbstractComponent
__precompile__()
dir::String = @__DIR__
res::String = dir * "/../resources"

struct CloreplethResource
    uri::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

def_names = Dict{String, Vector{Pair{String, String}}}("landxx" => ["fill"  => "lightgray", "stroke" => "#333333", "stroke-width" => ".5"], 
"oceanxx" => ["fill" => "lightblue"],
"coastxx" => ["fill"  => "lightgray", "stroke" => "#333333", "stroke-width" => ".5"], 
"subxx" => ["fill"  => "lightgray", "stroke" => "#333333", "stroke-width" => ".5"], 
"antxx" => ["fill"  => "white", "stroke" => "blue", "stroke-width" => ".5"], 
"noxx" => ["fill"  => "white", "stroke" => "blue", "stroke-width" => ".5"],
"limitxx" => ["fill"  => "white", "stroke" => "blue", "stroke-width" => ".5"], 
"unxx" => ["opacity" => "0%"], 
"eu" => ["fill"  => "blue", "stroke" => "#333333", "stroke-width" => ".5"], 
"circlexx" => ["opacity" => "0%"])

const world_map = CloreplethResource(res * "/world.svg", 2754 => 1398, def_names)

function clorepleth(x::Vector{String}, y::Vector{<:Number}, rs::CloreplethResource, colors::Vector{String} = ["red", "pink"])
    maxy::Number = maximum(y)
    pleth::Context = context(rs.dim[1], rs.dim[2]) do con::Context
        con.window[:text] = replace(read(rs.uri, String), "\"" => "'")
    end
    pleth.window[:children] = Vector{AbstractComponent}([begin 
        Gattino.ToolipsSVG.Style("." * def, rs.names[def] ...)
    end for def in keys(rs.names)])
    n::Int64 = length(colors)
    [begin
        found = Int64(ceil((y[e] / maxy) * n))
        push!(pleth.window, Gattino.ToolipsSVG.Style("." * def, "fill" => colors[found]))
    end for (e, def) in enumerate(x)]
    scale!(pleth, rs.dim[1], rs.dim[2])
    pleth::Context
end

function scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
    con.window["viewBox"] = "$x $y $w $h"
end

export clorepleth, scale!
end # module GattinoPleths
