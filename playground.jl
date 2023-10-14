include("src/simulation.jl")

using .GeneralizedUnreliableJacksonSim



L=5
alpha_vector = ones(5)
mu_vector = collect(1:5)
P = [0  .8   0    0   0;
    0   0   .8   0   0;
    0   0   0    .8  0;
    0   0   0    0   .8;
    .8  0   0    0    0]
c_s = 1
gamma_1 = 0.001
gamma_2 = 1

scenario = NetworkParameters(L, alpha_vector, mu_vector, P, c_s, gamma_1, gamma_2)

sim_net(scenario)
