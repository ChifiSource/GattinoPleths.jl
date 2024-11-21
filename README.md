<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattinopleths.png" width=350></img>
</div>

`GattinoPleths` provides the [Gattino](https://github.com/ChifiSource/Gattino.jl) ecosystem with choropleth visualizations. This allows us to display continuous data using a geographical feature.
###### usage
Usage revolves around the `choropleth` function:
```julia
choropleth(x::Vector{String}, y::Vector{<:Number}, rs::ChoroplethResource, colors::Vector{String} = Gattino.make_gradient((255, 255, 255), 10, 0, 0, -5))
choropleth(x::Vector{<:Any}, y::Vector{<:Number}, rs::RemoteChoroplethResource, args ...)
```
To this `Function`, we provide the two vectors we want to visualize. The `x` will be all-lowercase name abbreviations and the `y` will be our values. This is followed by a `CloreplethResource` or `RemoteCloreplethResource`, which will determine the map we load in the first place. Finally, `colors` is a `Vector` of colors, ideally a gradient -- easily created with `Gattino.make_gradient((R, G, B), length, scaler_r, scaler_g, scaler_b)`.

```julia
using GattinoPleths
using GattinoPleths.Gattino
reds = Gattino.make_gradient((255, 255, 255), 10, 0, 0, -5))
countries = ["mx", "us", "ca", "uk", "br", "au", "it", "ch", "ru", "in", "cn", "gl", "af", "bd", "jp", "iq"]
pleth = choropleth(countries, [rand(1:100) for c in countries], GattinoPleths.world_map, reds)
```
<img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattino_1_sc/Screenshot%20from%202024-05-05%2004-26-35.png"></img>

From here, we can use `scale!` to scale our image and `GattinoPleths.choropleth_legend!`.
```julia
scale!(con::Context, w::Int64, h::Int64, x::Int64 = 0, y::Int64 = 0)
choropleth_legend!(con::Gattino.AbstractContext, x::Pair{String, String}, colors::Vector{String}; align::String = "top-left")
```
- As of right now, (`0.0.9`), the following resources ship with `GattinoPleths`:
```julia
world_map
europe_map (remote resource)
usa_map ( remote resource)
```

To learn more about mutating `Gattino` plots and using the `Context`, see [Gattino](https://github.com/ChifiSource/Gattino.jl)
