include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra

include("scenarios.jl")


function plot_simulated_R(parameters::NetworkParameters, scenario_number::Int)
    Rs = 0.1:0.01:1
    simulated_Rs = [Vector{Float64}(undef, length(Rs)) for _ in 1:min(parameters.L, 10)]
    max_time = 1000

    for (i, R) in enumerate(Rs)
        new_parameters = set_scenario(parameters, R = R)
    
        riemann_sums = [0.0 for _ in 1:parameters.L]
        last_time = 0.0
    
        function record_integral(state::NetworkState, time::Float64)
            for q in 1:parameters.L
                (state.server_status[q] == 1) && (riemann_sums[q] += (time - last_time))
            end
            last_time = time
        end
    
        sim_net(new_parameters, max_time = max_time, callback = record_integral)
        
        for j in 1:min(parameters.L, 10)
            if riemann_sums[j] > 1100
                @show R
            end
            simulated_Rs[j][i] = riemann_sums[j] / max_time
        end
        
    end

    plot(Rs, simulated_Rs, title = "Scenario $(scenario_number)", 
    xlabel = "theoretical R", ylabel = "simulated R", 
    legend = false)
end


scenarios = [scenario1,scenario2,scenario3,scenario4]

for (i, scenario) in enumerate(scenarios)
    p = plot_simulated_R(scenario, i)
    savefig(p,"img/task_3_test_3_scenario_$(i).png") 
end
