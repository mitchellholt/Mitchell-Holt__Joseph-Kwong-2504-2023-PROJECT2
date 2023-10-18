@with_kw struct NetworkParameters 
    L::Int
    alpha_vector::Vector{Float64} 
    mu_vector::Vector{Float64} 
    P::Matrix{Float64} 
    c_s::Float64 = 1.0
    gamma_1::Float64 = 0
    gamma_2::Float64 = 1.0
end

function compute_lambda(parameters::NetworkParameters) 
    return (I - parameters.P') \ parameters.alpha_vector 
end

function compute_rho(parameters::NetworkParameters) 
    lambda = compute_lambda(parameters)
    return lambda ./ parameters.mu_vector  
end

function compute_R(parameters::NetworkParameters) 
    return parameters.gamma_2/(parameters.gamma_1 + parameters.gamma_2)
end


function maximal_alpha_scaling(parameters::NetworkParameters)
    lambda_base = (I - parameters.P') \ parameters.alpha_vector  
    rho_base = lambda_base ./ parameters.mu_vector  
    return minimum(1 ./ rho_base)
end

function set_scenario(parameters::NetworkParameters; rho_star::Float64, c_s::Float64=1.0, R::Float64 = 1.0)
    (rho_star <= 0 || rho_star >= 1) && error("Rho is out of range")
    (R <= 0 || R > 1) && error("R is out of range")
    max_scaling = maximal_alpha_scaling(parameters)
    parameters = @set parameters.gamma_1 = parameters.gamma_2 * (1-R)/R
    parameters = @set parameters.alpha_vector = parameters.alpha_vector * max_scaling * rho_star
    parameters = @set parameters.c_s = c_s
    return parameters
end

function service_capacity(parameters::NetworkParameters) 
    return compute_R(parameters) * parameters.mu_vector
end
