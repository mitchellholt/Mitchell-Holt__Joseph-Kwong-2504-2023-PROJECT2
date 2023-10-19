
rate_scv_gamma(rate::Float64, scv::Float64) = Gamma(1/scv, scv/rate)


function next_arrival_duration(state::S, q::Int) where {S <: State}
    return rand(Exponential(1/state.parameters.alpha_vector[q]))
end

function next_service_duration(state::S, q::Int) where {S <: State}
    return rand(rate_scv_gamma(state.parameters.mu_vector[q], state.parameters.c_s))
end

function next_off_duration(state::NetworkState) 
    return rand(Exponential(1/state.parameters.gamma_1))
end

function next_on_duration(state::NetworkState) 
    return rand(Exponential(1/state.parameters.gamma_2))
end

function next_location(state::NetworkState, q::Int)
    L = state.parameters.L 
    P = state.parameters.P
    weights = [P[q,:];[1 - sum(P[q,:])]]
    #@show weights
    return sample(1:L+1, Weights(weights))
end
