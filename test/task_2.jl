include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra

include("scenarios.jl")

function plot_theoretical_mean_queue_length(parameters::NetworkParameters, scenario_number::Int)
    rho_stars = 0.1:0.01:0.9
    theoretical_mean_queue_lengths = zeros(length(rho_stars))

    for (i, rho_star) in enumerate(rho_stars)
        rho = compute_rho(set_scenario(parameters, rho_star))
        theoretical_mean_queue_lengths[i] = sum(rho ./ (1 .- rho))
    end

    plot(rho_stars, 
        theoretical_mean_queue_lengths, 
        title = "Scenario $(scenario_number)",
        xlabel = "rho star",
        ylabel = "Mean queue lengths")

    savefig("img/task_2_scenario$(scenario_number).png") 
end

plot_theoretical_mean_queue_length(scenario1, 1)
plot_theoretical_mean_queue_length(scenario2, 2)
plot_theoretical_mean_queue_length(scenario3, 3)
plot_theoretical_mean_queue_length(scenario4, 4)

