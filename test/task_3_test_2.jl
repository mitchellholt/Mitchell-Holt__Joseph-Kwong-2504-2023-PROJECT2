include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra

include("scenarios.jl")


scenarios = [scenario1, scenario2, scenario3, scenario4]
c_s_values = [0.1,0.5,1,2,4]
max_time = 10^5
rho_star = 0.1

for (i, scenario) in enumerate(scenarios)
    println()
    println("Scenario $(i):")
    for c_s in c_s_values
        scenario = set_scenario(scenario, rho_star = rho_star, c_s = c_s_values[i])
        state = NetworkState(scenario)
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
