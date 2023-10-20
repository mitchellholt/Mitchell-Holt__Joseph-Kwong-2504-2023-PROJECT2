#############################################################################
#############################################################################
#
# This file runs the code needed for task 2, 3, 4 and 5.
#                                                                               
#############################################################################
#############################################################################

include("src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra, StatsBase

include("test/scenarios.jl")

include("test/task_2.jl")
include("test/task_3_test_1.jl")
include("test/task_3_test_2.jl")
include("test/task_3_test_3.jl")
include("test/task_3_test_4.jl")
include("test/task_4.jl")
include("test/task_5.jl")

scenarios = [scenario1, scenario2, scenario3, scenario4]



for (i, scenario) in collect(enumerate(scenarios))
    p = plot_simulated_R(scenario, i)
    savefig(p,"img/task_3_test_3_scenario_$(i)_new.png")
    println("Task 3 test 3 completed for scenario $(i).")
end

println("In task 2, we plot the theoretical total mean queue lengths for 
different values of rho^*.")
for (i, scenario) in enumerate(scenarios)
    plot_theoretical_mean_queue_length(scenario, i)
    savefig("img/task_2_scenario_$(i).png") 
    println("Task two completed for scenario $(i).")
end

println()
println("In task 3 test 1, we plot the theoretical and simulated mean 
queue lengths for different values of rho^*.")
for (i, scenario) in enumerate(scenarios)
    p1, p2 = plot_simulated_mean_queue_length(scenario, i)
    savefig(p1,"img/task_3_test_1_scenario_$(i)_simulated.png") 
    savefig(p2,"img/task_3_test_1_scenario_$(i)_error.png") 
    println("Task 3 test 1 completed for scenario $(i).")
end

println()
println("In task 3 test 2, we print the theoretical and simulated arrival rates.")
for (i, scenario) in enumerate(scenarios)
    println("Scenario $(i):")
    compare_arrival_rates(scenario, i)
    println()
end

println("In task 3 test 3, we plot the simulated R value against the 
theoretical R value.")
for (i, scenario) in collect(enumerate(scenarios))
    p = plot_simulated_R(scenario, i)
    savefig(p,"img/task_3_test_3_scenario_$(i).png")
    println("Task 3 test 3 completed for scenario $(i).")
end

println()
println("In task 3 test 4, we plot the simulated mean total queue length
against different values of R.")
for (i, scenario) in enumerate(scenarios)
    p = plot_R_versus_mean_queue_length(scenario, i)
    savefig(p,"img/task_3_test_4_scenario_$(i).png") 
    println("Task 3 test 4 completed for scenario $(i).")
end

println()
println("In task 4, we plot the simulated mean total queue length
against rho^*, for different values of c_s and R.")
for (i, scenario) in enumerate(scenarios)
    p1, p2 = plot_mean_queue_length_different_R_and_c_s(scenario, i)
    savefig(p1,"img/task_4_scenario_$(i)_different_R.png") 
    savefig(p2,"img/task_4_scenario_$(i)_different_c_s.png") 
    println("Finished scenario $i")
end


println()
println("In task 5, we compute the first quartile, the median and the third 
quartile of the sojourn times of the customers.")
for (i, scenario) in enumerate(scenarios)
    println("\nScenario $(i):")
    println("\t\t Q1 \t\t Median \t Q3")
    for c_s in [0.5,1.0,2.0]
        quantiles = estimate_q1_median_q3_customer_time(scenario, c_s)
        println("c_s = $(c_s) \t $(round(quantiles[1]; digits = 4))    \t $(round(quantiles[2]; digits = 4))    \t $(round(quantiles[3]; digits = 4))")
    end
end










