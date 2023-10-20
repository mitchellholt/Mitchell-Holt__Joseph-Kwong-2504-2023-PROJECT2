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

println("Doing task 2:")
for (i, scenario) in enumerate(scenarios)
    plot_theoretical_mean_queue_length(scenario, i)
    savefig("img/task_2_scenario_$(i).png") 
end

println("Doing task 3 test 1:")
for (i, scenario) in enumerate(scenarios)
    p1, p2 = plot_simulated_mean_queue_length(scenario, i)
    savefig(p1,"img/task_3_test_1_scenario_$(i)_simulated.png") 
    savefig(p2,"img/task_3_test_1_scenario_$(i)_error.png") 
    println("Finished scenario $i")
end

println("Doing task 3 test 2:")
for (i, scenario) in enumerate(scenarios)
    println()
    println("Scenario $(i):")
    compare_arrival_rates(scenario, i)
end

println("Doing task 3 test 3:")
for (i, scenario) in collect(enumerate(scenarios))
    p = plot_simulated_R(scenario, i)
    savefig(p,"img/task_3_test_3_scenario_$(i).png")
    println("Finished scenario $i")
end

println("Doing task 3 test 4:")
for (i, scenario) in enumerate(scenarios)
    p = plot_R_versus_mean_queue_length(scenario, i)
    savefig(p,"img/task_3_test_4_scenario_$(i).png") 
    println("Finished scenario $i")
end

println("Doing task 4:")
for (i, scenario) in enumerate(scenarios)
    p1, p2 = plot_mean_queue_length_different_R_and_c_s(scenario, i)
    savefig(p1,"img/task_4_scenario_$(i)_different_R.png") 
    savefig(p2,"img/task_4_scenario_$(i)_different_c_s.png") 
    println("Finished scenario $i")
end

println("Doing task 5:")
for (i, scenario) in enumerate(scenarios)
    println("\nScenario $(i):")
    println("\t\t Q1 \t\t Median \t Q3")
    for c_s in c_s_s
        quantiles = estimate_q1_median_q3_customer_time(scenario, c_s)
        println("c_s = $(c_s) \t $(round(quantiles[1]; digits = 4)) \t $(round(quantiles[2]; digits = 4)) \t $(round(quantiles[3]; digits = 4))")
    end
end


