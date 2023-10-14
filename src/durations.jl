
rate_scv_gamma(rate::Float64, scv::Float64) = Gamma(1/scv, scv/rate)

function next_arrival_duration(state::NetworkStateState, q::Int) 
    return rand(Exponential(1/state.parameters.alpha_vector[q]))
end

function next_service_duration(state::NetworkStateState, q::Int) 
    return rand(rate_scv_gamma(state.parameters.mu_array[q], state.parameters.c_s))
end