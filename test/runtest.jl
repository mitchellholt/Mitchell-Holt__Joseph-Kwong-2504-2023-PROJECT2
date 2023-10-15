include("../src/simulation.jl")

using Main.GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra

include("task_3.jl")
include("scenarios.jl")

# Task 3 -- test 1
# TODO adjust the max_time and run again so that we can be more confident in the
# correctness of the simulation code
plot_theoretical_actual_no_breakdown(scenario1, 1)
plot_theoretical_actual_no_breakdown(scenario2, 2)
plot_theoretical_actual_no_breakdown(scenario3, 3)
plot_theoretical_actual_no_breakdown(scenario4, 4)
