include("src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra
include("test/scenarios.jl")



scenario = set_scenario(scenario1; R = 0.5)
sim_net(scenario,max_time = 10)



