#############################################################################
#############################################################################
#
# This file implements our solution for task 2.
#                                                                               
#############################################################################
#############################################################################

"""
Returns a plot of the theoretical total mean queue length for different values of rho^*.
"""
function plot_theoretical_mean_queue_length(parameters::NetworkParameters, scenario_number::Int)
    rho_stars = 0.1:0.01:0.9
    theoretical_mean_queue_lengths = zeros(length(rho_stars))

    for (i, rho_star) in enumerate(rho_stars)
        rho = compute_rho(set_scenario(parameters, rho_star = rho_star))
        theoretical_mean_queue_lengths[i] = sum(rho ./ (1 .- rho))
    end

    plot(rho_stars, 
        theoretical_mean_queue_lengths, 
        title = "Scenario $(scenario_number)",
        xlabel = "rho star",
        ylabel = "mean total queue length")
end


