include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra
import Base.Threads.@threads

include("scenarios.jl")

function plot_simulated_mean_queue_length(parameters::NetworkParameters, scenario_number::Int;
    max_time = 10^6, warm_up_time = 10^4)
    rho_stars = 0.1:0.01:0.9

    simulation_results = Vector{Float64}(undef, length(rho_stars))
    theoretical_results = Vector{Float64}(undef, length(rho_stars))
    absolute_relative_errors = Vector{Float64}(undef, length(rho_stars))

    for (i, r) in collect(enumerate(rho_stars)) 
        new_parameters = set_scenario(parameters, rho_star = r)

        riemann_sum = 0
        last_time = 0.0

        function record_integral(state::NetworkState, time::Float64)
            (time >= warm_up_time) && (riemann_sum += sum(state.queues) * (time - last_time))
            last_time = time
        end

        sim_net(new_parameters, max_time = max_time, warm_up_time = warm_up_time,
            callback = record_integral)

        simulation_results[i] = riemann_sum / (max_time - warm_up_time)

        rho = compute_rho(new_parameters)
        theoretical_results[i] = sum(rho ./ (1 .- rho))

        absolute_relative_errors[i] = abs((simulation_results[i] - theoretical_results[i]) / theoretical_results[i])
    end
    
    p1 = plot(rho_stars, theoretical_results)
    p2 = plot(rho_stars, simulation_results) 
    p3 = plot(rho_stars, absolute_relative_errors)

    return p1,p2,p3
end

p1, p2,p3 = plot_simulated_mean_queue_length(scenario3, 3, max_time = 1000, warm_up_time = 100)
plot(p3)
savefig("img/task_3_scenario_1.png") 