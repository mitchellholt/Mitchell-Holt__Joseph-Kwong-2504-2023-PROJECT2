include("../src/simulation.jl")

using Main.GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra
import Base.Threads.@threads

include("task_2.jl")
include("task_3.jl")
include("scenarios.jl")



plot_theoretical_mean_queue_length(scenario1, 1)
plot_theoretical_mean_queue_length(scenario2, 2)
plot_theoretical_mean_queue_length(scenario3, 3)
plot_theoretical_mean_queue_length(scenario4, 4)

plot_theoretical_actual_no_breakdown(scenario1, 1)
plot_theoretical_actual_no_breakdown(scenario2, 2)
plot_theoretical_actual_no_breakdown(scenario3, 3)
plot_theoretical_actual_no_breakdown(scenario4, 4)
