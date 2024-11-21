"""
#### GattinoPleths - choropleth visualizations for Gattino
- Created in November, 2024 by [chifi](https://github.com/orgs/ChifiSource)
- This software is MIT-licensed.

`GattinoPleths` adds a simple choropleth interface to the `Gattino` visualization library.
###### contents
```julia
AbstractChoroplethResource
ChoroplethResource
RemoteChoroplethResource
download_resource(resource::RemoteChoroplethResource, uri::String = pwd())

world_map
europe_map
usa_map

choropleth_legend!(con::Gattino.AbstractContext, x::Pair{String, String}, colors::Vector{String}; align::String = "top-left")

choropleth(x::Vector{String}, y::Vector{<:Number}, rs::ChoroplethResource, colors::Vector{String} = ["red", "pink"])
choropleth(x::Vector{<:Any}, y::Vector{<:Number}, rs::RemoteChoroplethResource, args ...)
```
"""
module GattinoPleths
using Gattino
using Gattino.ToolipsSVG.ToolipsServables: AbstractComponent
using Gattino.ToolipsSVG

const DLS = Base.Downloads()

__precompile__()
dir::String = @__DIR__
res::String = dir * "/../resources"

"""
### abstract type AbstractChoroplethResource
An `AbstractChoroplethResource` describes a file or URL location from which 
we are able to access a `GattinoPleths`-prepared SVG file.
- See also: `ChoroplethResource`, `RemoteChoroplethResource`
##### consistencies
- `dim`**::Pair{Int64, Int64}**
- `names`**::Dict{String, Vector{Pair{String, String}}}
"""
abstract type AbstractChoroplethResource end

"""
```julia
ChoroplethResource <: AbstractChoroplethResource
```
- uri**::String**
- dim**::Pair{Int64, Int64}**
- names**::Dict{String, Vector{Pair{String, String}}}**

The `ChoroplethResource` is the *local* `AbstractChoroplethResource`, providing a local SVG 
file as a choropleth resource.

- See also: `AbstractChoroplethResource`, `RemoteChoroplethResource`, `choropleth`
```julia
ChoroplethResource(::String, ::Pair{Int64, Int64}, ::Dict{String, Vector{String, String}})
```
---
```example
const new_map = ChoroplethResource(pwd() * "/map.svg.svg", 2754 => 1398, Dict{String, Vector{Pair{String, String}}}())
# from `RemoteChoroplethResource`:
const local_euro = download_resource(GattinoPleths.euro_map, new_map.svg)
# (this is done automatically for us if we call choropleth on a Remote resource.)
```
"""
struct ChoroplethResource <: AbstractChoroplethResource
    uri::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

"""
```julia
RemoteChoroplethResource <: AbstractChoroplethResource
```
- name**::String**
- url**::String**
- dim**::Pair{Int64, Int64}**
- names**::Dict{String, Vector{Pair{String, String}}}**

The `RemoteChoroplethResource is the **remote** counter-part to the standard `ChoroplethResource`. 
Rather than storing the source SVG file in a local URI, we download it on command from a given `url`. 
`name` is provided as a default name for the file. We are able to save the file with custom naming 
    with `download_resource`, but when using `choropleth` on a remote source the file will
    automatically be downloaded to its name. The `RemoteChoroplethResource` may either be 
    provided directly to `choropleth`, or downloaded into a `ChoroplethResource` and then provided as 
    is done by the `RemoteChoroplethResource` binding of `choropleth`

- See also: `AbstractChoroplethResource`, `ChoroplethResource`, `choropleth`, `download_resource`
```julia
RemoteChoroplethResource(::String, ::String, ::Pair{Int64, Int64}, ::Dict{String, Vector{String, String}})
```
---
```example
# euromap example:
const europe_map = RemoteChoroplethResource("europe", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/europe/europe_map.svg", 
680 => 520, Dict{String, Vector{Pair{String, String}}}())

# downloading resource
const local_euro = download_resource(GattinoPleths.euro_map, new_map.svg)
```
"""
struct RemoteChoroplethResource <: AbstractChoroplethResource
    name::String
    url::String
    dim::Pair{Int64, Int64}
    names::Dict{String, Vector{Pair{String, String}}}
end

"""
```julia
download_resource(rm::RemoteChoroplethResource, uri::String = pwd()) -> ::ChoroplethResource
```
Downloads a `RemoteChoroplethResource`, providing a normal `ChoroplethResource` corresponding 
to the newly downloaded file in return. When calling this function, the resource will download 
to the provided `uri`. When this function is called from `choropleth`, it will automatically download 
the file into a new `uri` at `pwd` * `RemoteChoroplethResource.name`.
---
```example
const europe_map = RemoteChoroplethResource("europe", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/europe/europe_map.svg", 
680 => 520, Dict{String, Vector{Pair{String, String}}}())

local_euro_resource = download_resource(rm, "sample.svg")

choropleth = choropleth(x, y, local_euro_resource)

# we can also skip the `download_resource` step to implicitly download the file 
#   under the `RemoteChoroplethResource`'s `name`.

choropleth(x, y, europe_map)
```
"""
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

const europe_map = RemoteChoroplethResource("europe", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/europe/europe_map.svg", 
680 => 520, Dict{String, Vector{Pair{String, String}}}())

const usa_map = RemoteChoroplethResource("usa", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/united%20states/us.svg")

"""
```julia
choropleth_legend!(con::Gattino.AbstractContext, x::Pair{String, String}, colors::Vector{String}) -> ::Nothing
```
The `choropleth_legend!` function adds a legend to an existing choropleth. This will create 
    a " two-point" legend -- labeling each end of the gradient. Future versions will also 
    implement a `(::AbstractContext, xcolors::Vector{Pair{String, String}})` method for labeling 
        certain colors as categories directly.
---
```example
# create 'euro' choropleth:
pleth2 = choropleth(["de", "fr", "it"], [5, 45, 30], GattinoPleths.euromote_test, red_and_blue)
# add a legend:
GattinoPleths.choropleth_legend!(pleth2, "low" => "high", red_and_blue, align = "top-left") 
```
"""
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

"""
```julia
choropleth(x::Vector, y::Vector{<:Number}, resource::AbstractChoroplethResource, args ...) -> ::Gattino.Context
```
The `choropleth` function will create a choropleth from geographic labels (x),
a continuous feature (y), a choropleth resource file (resource, an `AbstractChoroplethResource`), and 
a provided `Vector` of colors. There is a dispatch for both a local `ChoroplethResource` and the 
remote `RemoteChoroplethResource`. The latter will download a new file into an SVG file named 
after the resource in your current working directory. Storing in your working directory is optional, 
but in order to store elsewhere, use `download_resource` to " convert" a remote resource into a local one.
```julia
choropleth(x::Vector{String}, y::Vector{<:Number}, rs::ChoroplethResource, colors::Vector{String}) -> ::Context
choropleth(x::Vector{<:Any}, y::Vector{<:Number}, rs::RemoteChoroplethResource, args ...) -> ::Context
```
---
```example
countries = ["mx", "us", "ca", "uk", "br", "au", "it", "ch", "ru", "in", "cn", "gl", "af", "bd", "jp", "iq"]
pleth = choropleth(countries, [rand(1:100) for c in countries], GattinoPleths.world_map, red_and_blue)
```
"""
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

"""
```julia
scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
```
Scales a `Gattino` `Context`to `w` and `h` dimensions from position `y`. This allows us to 
zoom into our visualization, or set a certain part of our visualization to be visualized.
---
```example
pleth2 = choropleth(["de", "fr", "it"], [5, 45, 30], GattinoPleths.euromote_test, red_and_blue)
scale!(pleth2, 500, 500, 200, 250)
```
"""
function scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
    con.window["viewBox"] = "$x $y $w $h"
end

export choropleth, scale!
end # module GattinoPleths
