include("../src/simulation.jl")
using .GeneralizedUnreliableJacksonSim, Plots, Parameters, Accessors, Random, LinearAlgebra, StatsBase

include("scenarios.jl")

function estimate_q1_median_q3_customer_time(
        parameters :: NetworkParameters, c_s :: Float64) :: Vector{Float64}

    rho_star = 0.8

    customers = sim_net_customers(
        set_scenario(parameters, rho_star = rho_star, c_s = c_s)).customers
    data = [c.departure_time - c.arrival_time for c in customers if c.departure_time > 0]

    return nquantile(data, 4)[2:4]
end


scenarios = [scenario1, scenario2, scenario3, scenario4]
c_s_s = [0.5, 1.0, 2.0]

for (i, scenario) in enumerate(scenarios)
    println("Scenario $(i):")
    println("\t Q1 \t Median \t Q3")
    for c_s in c_s_s
        quantiles = estimate_q1_median_q3_customer_time(scenario, c_s)
        println("c_s = $(c_s) \t $(quantiles[1]) \t $(quantiles[2]) \t $(quantiles[3])")
    end
end
