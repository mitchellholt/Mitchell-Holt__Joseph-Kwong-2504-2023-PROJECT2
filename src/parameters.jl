

struct NetworkParameters 
    L::Int
    alpha_vector::Vector{Float64} 
    mu_vector::Vector{Float64} 
    P::Matrix{Float64} 
    c_s::Float64 
    gamma_1::Float64 
    gamma_2::Float64 
    #NetworkParameters(a,b,c,d,e,f,g) = new(a,b,c,d,e,f,g)
end