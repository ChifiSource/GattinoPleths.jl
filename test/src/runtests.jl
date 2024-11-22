using Test
using GattinoPleths
using GattinoPleths: RemoteChoroplethResource, ChoroplethResource, download_resource, choropleth_legend!
@testset "GattinoPleths" verbose = true begin
    @testset "resource tests" verbose = true begin
        rs = nothing
        @testset "resource constructors" begin
            new_resource = GattinoPleths.ChoroplethResource("../", 500 => 500, Dict{String, Vector{Pair{String, String}}}())
            @test new_resource.uri == "../"
            rs = RemoteChoroplethResource("usa", "https://raw.githubusercontent.com/ChifiSource/GattinoPleths-Resources/refs/heads/main/united%20states/us.svg", 
            959 => 593, Dict{String, Vector{Pair{String, String}}}())
            @test rs.name == "usa"
        end
        @testset "download resource" begin 
            new_rs = download_resource(rs)
            @test typeof(new_rs) == ChoroplethResource
            @test isfile(new_rs.uri)
            @test contains(new_rs.uri, "usa.svg")
        end
    end
    @testset "choropleths" begin
        @testset "choropleth" begin
            new_pleth = choropleth(["it", "de", "fr", "uk"], [552, 23, 22, 43], GattinoPleths.europe_map)
            all_styles = [style.name for style in new_pleth[:children]]
            @test ".it" in all_styles
            @test ".de" in all_styles
            @test ".uk" in all_styles
            @test (contains(new_pleth[:children][".it"][:fill], "rgb"))
            new_pleth = choropleth(["fr", "uk", "bz", "mx", "us"], [223, 92, 33, 24, 32], GattinoPleths.world_map)
            all_styles = [style.name for style in new_pleth[:children]]
            @test ".us" in all_styles
            @test typeof(new_pleth) == GattinoPleths.Gattino.Context
            new_pleth = choropleth(["nm", "ny", "ky", "ga"], [552, 23, 22, 43], GattinoPleths.usa_map)
            @test contains(new_pleth[:text], "<path")
            @test typeof(new_pleth) == GattinoPleths.Gattino.Context
        end
        @testset "choropleth legends" begin
            new_pleth = choropleth(["nm", "ny", "ky", "ga"], [552, 23, 22, 18], GattinoPleths.usa_map)
            len = length(new_pleth[:text])
            choropleth_legend!(new_pleth, "dry" => "wet", GattinoPleths.Gattino.make_gradient((255, 0, 0), 10, -25, 0, 25), align = "bottom-right")
            @test length(new_pleth[:text]) > len
            @test contains(new_pleth[:text], "<text") && contains(new_pleth[:text], "dry")
            @test contains(new_pleth[:text], "wet")
        end
    end
end