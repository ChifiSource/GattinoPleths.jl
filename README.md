<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattinopleths.png"></img>
</div>

`GattinoPleths` provides the [Gattino](https://github.com/ChifiSource/Gattino.jl) ecosystem with clorepleth visualizations. This allows us to display continuous data using a geographical feature. Though this package is still in early development, it is easy to see where things are going ...
```julia
pleth = clorepleth(["us", "mx"], [5, 10], GattinoPleths.world_map, ["red", "green", "blue"])
```
