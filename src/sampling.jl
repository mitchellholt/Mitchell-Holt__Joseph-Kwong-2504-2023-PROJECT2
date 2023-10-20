#############################################################################
#############################################################################
#
# This file implements all aspects of randomness in our simulation.
#                                                                               
#############################################################################
#############################################################################



"""
A convenience function to make a Gamma distribution with desired rate 
(inverse of shape) and SCV.
"""
rate_scv_gamma(rate::Float64, scv::Float64) = Gamma(1/scv, scv/rate)

"""
Generates the time until the next external arrival at the qth server.
"""
function next_arrival_duration(state::State, q::Int)
    return rand(Exponential(1/state.parameters.alpha_vector[q]))
end

"""
Generates the time it takes to process a job at the qth server.
"""
function next_service_duration(state::State, q::Int)
    return rand(rate_scv_gamma(state.parameters.mu_vector[q], state.parameters.c_s))
end

"""
Generates the time for a server to stay on.
"""
function next_off_duration(state::NetworkState) 
    return rand(Exponential(1/state.parameters.gamma_1))
end

"""
Generates the time for a server to stay off.
"""
function next_on_duration(state::NetworkState) 
    return rand(Exponential(1/state.parameters.gamma_2))
end

"""
Generates the next location for a job at the qth server after it 
has been served.
"""
function next_location(state::State, q::Int)
    L = state.parameters.L 
    P = state.parameters.P
    weights = [P[q,:];[1 - sum(P[q,:])]]
    #@show weights
    return sample(1:L+1, Weights(weights))
end
