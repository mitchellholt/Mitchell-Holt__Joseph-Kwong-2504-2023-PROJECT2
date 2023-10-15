"""
Keep track of a collection of running averages. Each average must be updated at
the same time
"""
mutable struct Averages
    num_updates :: Int
    average_list :: Vector{Float64}

    Averages(n) = new(0, zeros(Float64, n))
end

"""
Update the running averages in an Averages struct with a list of new values.
"""
function update_averages(averages :: Averages, new_values :: Vector{Float64})
    @assert length(new_values) == length(averages.average_list)
    n = averages.num_updates
    ls = averages.average_list
    ls = ((n .* ls) .+ new_values) ./ (n + 1)
    averages.average_list = ls # not sure if this is redundant?
    averages.num_updates = n + 1
end


# Task 3 test 1 -- compare with theoretical results from task 2
function plot_theoretical_actual_no_breakdown(
        parameters::NetworkParameters, scenario_number::Int;
        max_time = 10^6, warm_up_time = 10^4)

    rho_stars = 0.1:0.01:0.9
    simulation_results = Vector{Float64}(undef, length(rho_stars))
    theoretical_results = Vector{Float64}(undef, length(rho_stars))

    for (i, r) in enumerate(rho_stars)
        params = set_scenario(parameters, r)

        # SIMULATION
        mean_queue_lengths = Averages(params.L)
        callback(state) = update_averages(mean_queue_lengths, Float64.(state.queues))

        # assume we actually do reach steady state after warm-up time
        sim_net(params, max_time = max_time, warm_up_time = warm_up_time,
            callback = callback)

        simulation_results[i] = sum(mean_queue_lengths.average_list)

        # THEORETICAL
        rho = compute_rho(params)
        theoretical_results[i] = sum(rho ./ (1 .- rho))
    end

    results = @. abs(simulation_results - theoretical_results);
    plot(rho_stars, results)
    savefig("task_3_test_1_scenario$(scenario_number).png")
end
