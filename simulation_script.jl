include("src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra
include("test/scenarios.jl")



function test()
    scenario = set_scenario(scenario3; rho_star = 0.1)
    max_time = 100000
    warm_up_time = 50000
    riemann_sum = 0
    last_time = 0.0
    function record_integral(state::NetworkState, time::Float64)
        (time >= warm_up_time) && (riemann_sum += sum(state.queues) * (time - last_time))
        last_time = time
    end

    sim_net(scenario,max_time = max_time, callback = record_integral)
    @show riemann_sum / (max_time - warm_up_time)

    rho = compute_rho(scenario)
    @show sum(rho ./ (1 .- rho))
end

test()