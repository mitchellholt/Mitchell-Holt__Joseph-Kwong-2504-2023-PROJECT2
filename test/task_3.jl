# Task 3 test 1 -- compare with theoretical results from task 2
function plot_theoretical_actual_no_breakdown(
        parameters::NetworkParameters, scenario_number::Int;
        max_time = 10^6, warm_up_time = 10^4)

    rho_stars = 0.1:0.01:0.9
    simulation_results = Vector{Float64}(undef, length(rho_stars))
    theoretical_results = Vector{Float64}(undef, length(rho_stars))

    # turn on pro gamer mode, run with `--threads n` for n threads
    @threads for (i, r) in collect(enumerate(rho_stars))
        params = set_scenario(parameters, r)

        # SIMULATION
        riemann_sum = 0
        prev_time = warm_up_time
        function callback(state :: NetworkState, time :: Float64)
            riemann_sum += sum(state.queues) * (time - prev_time)
            prev_time = time
        end

        # assume we actually do reach steady state after warm-up time
        sim_net(params, max_time = max_time, warm_up_time = warm_up_time,
            callback = callback)
        simulation_results[i] = riemann_sum / (max_time - warm_up_time)

        # THEORETICAL
        rho = compute_rho(params)
        theoretical_results[i] = sum(rho ./ (1 .- rho))
    end

    results = @. abs(simulation_results - theoretical_results);
    plot(rho_stars, results)
    savefig("task_3_test_1_scenario$(scenario_number).png")
    println("Saved figure as task_3_test_1_scenario$(scenario_number).png")
end
