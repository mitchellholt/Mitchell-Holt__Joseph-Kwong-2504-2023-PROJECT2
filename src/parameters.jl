#############################################################################
#############################################################################
#
# This file implements parameters for our simulation.
#                                                                               
#############################################################################
#############################################################################

"""
This struct stores the parameters for a simulation.

    - L is the number of servers.
    - alpha_vector is a vector of external arrival rates.
    - mu_vector is a vector of services rates.
    - P is the L by L routing matrix.
    - c_s is the squared coefficients of the variation of service processes.
    - gamma_1 is the rate for "on" durations. 
    - gamma_2 is the rate for "off" durations. 
"""
@with_kw struct NetworkParameters 
    L::Int
    alpha_vector::Vector{Float64} 
    mu_vector::Vector{Float64} 
    P::Matrix{Float64} 
    c_s::Float64 = 1.0
    gamma_1::Float64 = 0
    gamma_2::Float64 = 1.0
end

"""
Computes the lambda vector given parameters.
"""
function compute_lambda(parameters::NetworkParameters) 
    return (I - parameters.P') \ parameters.alpha_vector 
end

"""
Computes the rho vector given parameters.
"""
function compute_rho(parameters::NetworkParameters) 
    lambda = compute_lambda(parameters)
    return lambda ./ parameters.mu_vector  
end

"""
Computes the proportion the servers are on, R, given parameters.
"""
function compute_R(parameters::NetworkParameters) 
    return parameters.gamma_2/(parameters.gamma_1 + parameters.gamma_2)
end

"""
Computes the vector R * mu, given parameters.
"""
function service_capacity(parameters::NetworkParameters) 
    return compute_R(parameters) * parameters.mu_vector
end

"""
Computes the maximal value for which we can scale alpha so that the parameter is 
still stable.
"""
function maximal_alpha_scaling(parameters::NetworkParameters)
    lambda_base = (I - parameters.P') \ parameters.alpha_vector  
    rho_base = lambda_base ./ parameters.mu_vector  
    return minimum(1 ./ rho_base)
end

"""
Adjust a scenario by choosing rho_star, c_s, and R.
"""
function set_scenario(parameters::NetworkParameters; rho_star::Float64=0.5, c_s::Float64=1.0, R::Float64 = 1.0)
    (rho_star <= 0 || rho_star >= 1) && error("Rho is out of range")
    (R <= 0 || R > 1) && error("R is out of range")
    parameters = @set parameters.gamma_1 = parameters.gamma_2 * (1-R)/R
    max_scaling = maximal_alpha_scaling(parameters)
    parameters = @set parameters.alpha_vector = parameters.alpha_vector * max_scaling * rho_star
    parameters = @set parameters.c_s = c_s
    return parameters
end


