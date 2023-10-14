

@with_kw struct NetworkParameters 
    L::Int
    alpha_vector::Vector{Float64} 
    mu_vector::Vector{Float64} 
    P::Matrix{Float64} 
    c_s::Float64 = 1.0
    gamma_1::Float64 = (10^-8)
    gamma_2::Float64 = 1.0
end

function compute_lambda(parameters::NetworkParameters) 
    return (I - parameters.P') \ parameters.alpha_vector 
end

function compute_rho(parameters::NetworkParameters) 
    lambda = compute_lambda(parameters)
    return lambda ./ parameters.mu_vector  
end


function maximal_alpha_scaling(parameters::NetworkParameters)
    lambda_base = (I - parameters.P') \ parameters.alpha_vector  
    rho_base = lambda_base ./ parameters.mu_vector  
    return minimum(1 ./ rho_base)
end

function set_scenario(parameters::NetworkParameters, rho::Float64, c_s::Float64=1.0)
    (rho <= 0 || rho >= 1) && error("Rho is out of range")
    max_scaling = maximal_alpha_scaling(parameters)
    parameters = @set parameters.alpha_vector = parameters.alpha_vector * max_scaling * rho
    parameters = @set parameters.c_s = c_s
    return parameters
end

function service_capacity(parameters::NetworkParameters) 
    return (parameters.gamma_2/(parameters.gamma_1 + parameters.gamma_2)) * parameters.mu_vector
end