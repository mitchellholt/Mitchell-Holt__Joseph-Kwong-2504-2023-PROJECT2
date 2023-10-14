module GeneralizedUnreliableJacksonSim

using StatsBase, Distributions, Random
include("network_parameters.jl")
include("state.jl")
include("sampling.jl")
include("events.jl")

function sim_net(net::NetworkParameters; max_time = 10^6, warm_up_time = 10^4, seed::Int64 = 42)::Float64
    
    Random.seed!(seed)
    
end;

end;
