#############################################################################
#############################################################################
#
# This file implements our solution for task 3 test 2.
#                                                                               
#############################################################################
#############################################################################

"""
Prints the simulated arrival rates and theoretical arrival rates for different 
values of c_s. We also print the sum of the square errors between the simulated 
and theoretical results.
"""
function compare_arrival_rates(parameters::NetworkParameters, scenario_number::Int)
    c_s_values = [0.1,0.5,1,2,4]
    max_time = 10^5
    rho_star = 0.5
    for c_s in c_s_values
        parameters = set_scenario(parameters, rho_star = rho_star, c_s = c_s_values[i])
        state = NetworkState(parameters)
        sim_net(scenario, state = state,max_time = max_time)
        println("c_s = $(c_s):")
        simulated_arrival_rates = state.arrivals/max_time 
        theoretical_arrival_rates = compute_lambda(scenario)
        sum_square_errors = sum((simulated_arrival_rates .- theoretical_arrival_rates).^2)
        println("The simulated arrival rates are: ", simulated_arrival_rates)
        println("The theoretical arrival rates are: ", theoretical_arrival_rates)
        println("The sum of square errors is: ", sum_square_errors)
    end
end