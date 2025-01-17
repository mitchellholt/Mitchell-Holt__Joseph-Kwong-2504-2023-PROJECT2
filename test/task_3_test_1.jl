#############################################################################
#############################################################################
#
# This file implements our solution for task 3 test 1.
#                                                                               
#############################################################################
#############################################################################

"""
Returns two plots, p1 and p2.

The first plot p1 shows the simulated total mean queue length and the 
theoretical result for different max times and values of rho^*.

The second plot p2 shows the absolute relative error between the simulated and theoretical 
results for different max times and values of rho^*.
"""
function plot_simulated_mean_queue_length(parameters::NetworkParameters, scenario_number::Int)
    rho_stars = 0.1:0.01:0.9
    max_times = [10^3,10^4,10^5]
    warm_up_times = [10^2,10^3,10^4]

    theoretical_results = Vector{Float64}(undef, length(rho_stars))
    for (i, rho_star) in collect(enumerate(rho_stars))
        new_parameters = set_scenario(parameters, rho_star = rho_star) 
        rho = compute_rho(new_parameters)
        theoretical_results[i] = sum(rho ./ (1 .- rho))
    end

    simulation_data = [theoretical_results]
    error_data = []

    for (i, max_time) in enumerate(max_times)
        warm_up_time = warm_up_times[i]
        simulation_results = Vector{Float64}(undef, length(rho_stars))
        absolute_relative_errors = Vector{Float64}(undef, length(rho_stars))

        for (i, rho_star) in collect(enumerate(rho_stars)) 
            new_parameters = set_scenario(parameters, rho_star = rho_star)

            riemann_sum = 0.0
            prev_total = 0.0
            prev_time = 0.0

            function record_integral(state::NetworkState, time::Float64)
                (time >= warm_up_time) && (riemann_sum += prev_total * (time - prev_time))
                prev_total = sum(state.queues)
                prev_time = time
            end

            sim_net(new_parameters, max_time = max_time, warm_up_time = warm_up_time,
                callback = record_integral)

            simulation_results[i] = riemann_sum / (max_time - warm_up_time)
            absolute_relative_errors[i] = abs((simulation_results[i] - theoretical_results[i]) / theoretical_results[i])
        end

        push!(simulation_data, simulation_results)
        push!(error_data, absolute_relative_errors)

    end
    
    
    p1 = plot(rho_stars, simulation_data, title = "Scenario $(scenario_number)", 
    xlabel = "rho star", ylabel = "mean total queue length", 
    labels=["theoretical" "max time = 1000" "max time = 10000"  "max time = 100000"])

    p2 = plot(rho_stars, error_data, title = "Scenario $(scenario_number)", 
    xlabel = "rho star", ylabel = "absolute relative error", 
    labels=["max time = 1000" "max time = 10000"  "max time = 100000"])
    return p1, p2
end


