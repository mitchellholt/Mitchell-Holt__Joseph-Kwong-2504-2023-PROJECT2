

struct NetworkParameters 
    L::Int
    alpha_vector::Vector{Float64} 
    mu_vector::Vector{Float64} 
    P::Matrix{Float64} 
    c_s::Float64 = 1.0 
    gamma_1::Float64 = (10^-8) 
    gamma_2::Float64 = 1.0 
end