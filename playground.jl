include("src/simulation.jl")

using .GeneralizedUnreliableJacksonSim, LinearAlgebra

L = 3
alpha_vector = [1,1,0.1]
mu_vector = [2,3,0.5]
P = [0 0.5 0;
    0 0 0.5;
    0.5 0 0]
c_s = 1
gamma_1 = 0
gamma_2 = 1
scenario = NetworkParameters(L, alpha_vector, mu_vector, P, c_s, gamma_1, gamma_2)

sim_net(scenario)

# theoretical arrival rate
lambda = (I - scenario.P') \ scenario.alpha_vector

@show lambda