#############################################################################
#############################################################################
#
# This file implements our solution for task 3 test 4.
#                                                                               
#############################################################################
#############################################################################

"""
Returns a plot which shows the mean total queue lengths for different values of R.
"""
function plot_R_versus_mean_queue_length(parameters::NetworkParameters, scenario_number::Int)
    Rs = 0.1:0.01:1
    max_time = 10000
    warm_up_time = 100

    data = [] 
    for rho_star in [0.6,0.7,0.8]
        mean_queue_lengths = Vector{Float64}(undef, length(Rs))
        for (i, R) in enumerate(Rs)
            new_parameters = set_scenario(parameters, R = R,rho_star = rho_star)

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

            mean_queue_lengths[i] = riemann_sum / (max_time - warm_up_time)
        end
        push!(data, mean_queue_lengths)
    end
    plot(Rs, data, title = "Scenario $(scenario_number)", 
    xlabel = "Theoretical R", ylabel = "mean total queue length", 
    labels=["rho^* = 0.6" "rho^* = 0.7"  "rho^* = 0.8"])
end




