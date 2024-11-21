module GattinoPleths
using Gattino
using Gattino.ToolipsSVG.ToolipsServables: AbstractComponent
using Gattino.ToolipsSVG

const DLS = Base.Downloads()

__precompile__()
dir::String = @__DIR__
res::String = dir * "/../resources"

abstract type AbstractChoroplethResource end

struct ChoroplethResource <: AbstractChoroplethResource
    uri::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

struct RemoteChoroplethResource <: AbstractChoroplethResource
    name::String
    url::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

download_resource(rm::RemoteChoroplethResource, uri::String = pwd()) = begin
    uri = uri * "/" * rm.name * ".svg"
    DLS.download(rm.url, uri)
    ChoroplethResource(uri, rm.dim, rm.names)::ChoroplethResource
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

const world_map = ChoroplethResource(res * "/world.svg", 2754 => 1398, def_names)

const europe_map = ChoroplethResource(res * "/europe_map.svg", 680 => 520, Dict{String, Vector{Pair{String, String}}}())

const euromote_test = RemoteChoroplethResource("europe", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/europe/europe_map.svg", 
680 => 520, Dict{String, Vector{Pair{String, String}}}())

function choropleth_legend!(con::Gattino.AbstractContext, x::Pair{String, String}, colors::Vector{String}; align::String = "top-left")
    scaler::Number = Int64(round(con.dim[1] * .50))
    positionx::Int64 = Int64(round(con.dim[1] / 2)) + con.margin[1]
    if contains(align, "right")
        positionx += scaler
    elseif contains(align, "left")
        positionx -= scaler
    end
    positiony::Int64 = Int64(round(con.dim[2] / 2)) + con.margin[2]
    scaler = Int64(round(con.dim[2] * .22))
    if contains(align, "top")
        positiony -= scaler
    elseif contains(align, "bottom")
        positiony += scaler
    end
    legend_height = con.dim[2] * .15
    legend_width = con.dim[1] * .20
    legend_bg = rect(width = legend_width, height = legend_height, x = positionx, y = positiony)
    style!(legend_bg, "fill" => "white", "stroke" => "#333333", "border-radius" => 3px, "stroke-width" => 2px)
    scaler = Int64(round(legend_width * .1))
    n = length(colors)
    grad_y = Int64(round(legend_height * .35)) + positiony
    grad_position = positionx + scaler
    grad::String = ""
    for x in range(.1, 1, step = .12)
        grad_box = rect(x = positionx + grad_position, y = grad_y,
        width = scaler, height = 3)
        style!(grad_box, "fill" => colors[Int64(round(x * n))])
        grad = grad * string(grad_box)
        grad_position += scaler
    end
    label_height = positiony + Int64(round(legend_height * .70))
    label1 = ToolipsSVG.text(x = positionx + scaler, y = label_height, text = x[1])
    label2 = ToolipsSVG.text(x = positionx + legend_width - (scaler * 3), y = label_height, text = x[2])
    style!(label1, "stroke" => "#333333")
    style!(label2, "stroke" => "#333333", "fill" => "blue")
    con.window[:text] = con.window[:text] * string(legend_bg) * grad * string(label1) * string(label2)
    nothing
end

function choropleth(x::Vector{String}, y::Vector{<:Number}, rs::ChoroplethResource, colors::Vector{String} = ["red", "pink"])
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

function choropleth(x::Vector{<:Any}, y::Vector{<:Number}, rs::RemoteChoroplethResource, args ...)
    rs = download_resource(rs)
    choropleth(x, y, rs, args ...)
end

function scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
    con.window["viewBox"] = "$x $y $w $h"
end

export choropleth, scale!
end # module GattinoPleths
