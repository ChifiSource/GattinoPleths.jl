<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattinopleths.png"></img>
</div>

`GattinoPleths` provides the [Gattino](https://github.com/ChifiSource/Gattino.jl) ecosystem with clorepleth visualizations. This allows us to display continuous data using a geographical feature.
###### proof of concept ...
```julia
using GattinoPleths
using GattinoPleths.Gattino
reds = ["#df1b1b", "#d62121", "	#ce2525", "#c72c2c", "#ba3030", "darkred"]
countries = ["mx", "us", "ca", "uk", "br", "au", "it", "ch", "ru", "in", "cn", "gl", "af", "bd", "jp", "iq"]
pleth = clorepleth(countries, [rand(1:100) for c in countries], GattinoPleths.world_map, reds)
```
<img src="https://github.com/ChifiSource/image_dump/blob/main/gattino/gattino_1_sc/Screenshot%20from%202024-05-05%2004-26-35.png"></img>

---
More pleths and capabilities will be built atop this interface.... I of course have a lot of other things to do, so I am not sure *how many maps* we will be getting, exactly. I do, however, plan to include a myriad of maps with the package and maybe in the future write some other resource packs!
