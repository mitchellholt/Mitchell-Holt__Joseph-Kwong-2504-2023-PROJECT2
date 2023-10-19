include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra

include("scenarios.jl")

function plot_mean_queue_length_different_R_and_c_s(parameters::NetworkParameters, scenario_number::Int)
    c_s_values = [0.1,0.5,1.0,2.0,4.0]
    R_values = [0.25, 0.75, 1.0]
    rho_stars = 0.1:0.01:0.9
    max_time = 1000
    warm_up_time = 100

    data = []
    for R in R_values
        simulation_results = Vector{Float64}(undef, length(rho_stars))
        for (i, r) in collect(enumerate(rho_stars)) 
            new_parameters = set_scenario(parameters, rho_star = r, c_s = 0.5, R = R)

            riemann_sum = 0
            last_time = 0.0

            function record_integral(state::NetworkState, time::Float64)
                (time >= warm_up_time) && (riemann_sum += sum(state.queues) * (time - last_time))
                last_time = time
            end

            sim_net(new_parameters, max_time = max_time, warm_up_time = warm_up_time,
                callback = record_integral)

            simulation_results[i] = riemann_sum / (max_time - warm_up_time)
        end
        push!(data, simulation_results)
    end

    p1 = plot(rho_stars, data, title = "Scenario $(scenario_number)", 
    xlabel = "rho star", ylabel = "mean total queue length", 
    labels = ["R = 0.25" "R = 0.75" "R = 1"])

    data = []
    for c_s in c_s_values
        simulation_results = Vector{Float64}(undef, length(rho_stars))
        for (i, r) in collect(enumerate(rho_stars)) 
            new_parameters = set_scenario(parameters, rho_star = r, c_s = c_s, R = 0.75)

            riemann_sum = 0
            last_time = 0.0

            function record_integral(state::NetworkState, time::Float64)
                (time >= warm_up_time) && (riemann_sum += sum(state.queues) * (time - last_time))
                last_time = time
            end

            sim_net(new_parameters, max_time = max_time, warm_up_time = warm_up_time,
                callback = record_integral)

            simulation_results[i] = riemann_sum / (max_time - warm_up_time)
        end
        push!(data, simulation_results)
    end

    p2 = plot(rho_stars, data, title = "Scenario $(scenario_number)", 
    xlabel = "rho star", ylabel = "mean total queue length", 
    labels = ["c_s = 0.1" "c_s = 0.5" "c_s = 1" "c_s = 2" "c_s = 4" ])

    return p1, p2
end

scenarios = [scenario1,scenario2,scenario3,scenario4]

for (i, scenario) in enumerate(scenarios)
    p1, p2 = plot_mean_queue_length_different_R_and_c_s(scenario, i)
    savefig(p1,"img/task_4_scenario_$(i)_different_R.png") 
    savefig(p2,"img/task_4_scenario_$(i)_different_c_s.png") 
end
