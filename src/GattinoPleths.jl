module GattinoPleths
using Gattino
using Gattino.ToolipsSVG.ToolipsServables: AbstractComponent
using Gattino.ToolipsSVG

const DLS = Base.Downloads()

__precompile__()
dir::String = @__DIR__
res::String = dir * "/../resources"

abstract type AbstractCloreplethResource end

struct CloreplethResource <: AbstractCloreplethResource
    uri::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

struct RemoteCloreplethResource <: AbstractCloreplethResource
    name::String
    url::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

download_resource(rm::RemoteCloreplethResource, uri::String = pwd()) = begin
    uri = uri * "/" * rm.name * ".svg"
    DLS.download(rm.url, uri)
    CloreplethResource(uri, rm.dim, rm.names)::CloreplethResource
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

const europe_map = CloreplethResource(res * "/europe_map.svg", 680 => 520, Dict{String, Vector{Pair{String, String}}}())

const euromote_test = RemoteCloreplethResource("europe", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/europe/europe_map.svg", 
680 => 520, Dict{String, Vector{Pair{String, String}}}())

function clorepleth_legend!(con::Gattino.AbstractContext, x::Vector{String}, y::Vector{<:Number}, colors::Vector{String}; align::String = "top-left")
    scaler::Int64 = Int64(round(con.dim[1] * .24))
    positionx::Int64 = Int64(round(con.dim[1] / 2)) + con.margin[1]
    if contains(align, "right")
        positionx += scaler
    elseif contains(align, "left")
        positionx -= scaler
    end
    positiony::Int64 = Int64(round(con.dim[2] / 2)) + con.margin[2]
    scaler = Int64(round(con.dim[2] * .20))
    if contains(align, "top")
        positiony -= scaler
    elseif contains(align, "bottom")
        positiony += scaler
    end
    legend_bg = rect(width = con.dim[1] * .1, height = con.dim[2] * .1, x = positionx, positiony = 55)
    style!(legend_bg, "fill" => "white", "stroke" => "2px solid #333333", "border-radius" => 3px)
    push!(con.window[:children], legend_bg)
    nothing
end

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
        push!(pleth.window, Gattino.ToolipsSVG.Style("." * def, "fill" => colors[found] * " !important"))
    end for (e, def) in enumerate(x)]
    scale!(pleth, rs.dim[1], rs.dim[2])
    pleth::Context
end

function clorepleth(x::Vector{<:Any}, y::Vector{<:Number}, rs::RemoteCloreplethResource, args ...)
    rs = download_resource(rs)
    clorepleth(x, y, rs, args ...)
end

function scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
    con.window["viewBox"] = "$x $y $w $h"
end

export clorepleth, scale!
end # module GattinoPleths
