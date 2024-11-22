using Test
using GattinoPleths
using GattinoPleths: RemoteChoroplethResource, ChoroplethResource, download_resource
@testset "GattinoPleths" verbose = true begin
    @testset "resource tests" verbose = true begin
        rs = nothing
        @testset "resource constructors" begin
            new_resource = GattinoPleths.ChoroplethResource("../", 500 => 500, Dict{String, Vector{String, String}}())
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

    end
end