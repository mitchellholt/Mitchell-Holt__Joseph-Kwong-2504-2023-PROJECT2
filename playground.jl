include("src/simulation.jl")

include("test/scenarios.jl")
using .GeneralizedUnreliableJacksonSim


plot_theoretical_mean_queue_length(parameters:NetworkParameters)
    rho_stars = 0.1:0.01:0.9
    theoretical_mean_queue_lengths = zeros(length(rho_stars))

    for (i, rho_star) in enumerate(rho_stars)
        rho = compute_rho(set_scenario(parameters, rho_star))
        theoretical_mean_queue_lengths[i] = sum(rho ./ (1 .- rho))
    end

    plot(rho_stars, theoretical_mean_queue_lengths)
end

plot_theoretical_mean_queue_length(scenario1)