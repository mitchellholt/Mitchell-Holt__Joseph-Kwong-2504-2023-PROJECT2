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
        prev_time = 0.0
        prev_status = [0 for _ in 1:parameters.L]
    
        function record_integral(state::NetworkState, time::Float64)
            riemann_sums = @. riemann_sums + ((time - prev_time) * prev_status)
            prev_status = copy(state.server_status)
            prev_time = time
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

for (i, scenario) in collect(enumerate(scenarios))
    p = plot_simulated_R(scenario, i)
    # TODO remove the _ in front of the filename once we happy with everything
    savefig(p,"img/task_3_test_3_scenario_$(i).png")
    println("Finished scenario $i")
end
