
abstract type State end

mutable struct NetworkState <: State 
    queues::Vector{Int64} # number of jobs in each queue
    server_status::Vector{Bool} # whether servers are on or off
    last_off_times::Vector{Float64}
    additional_times::Vector{Float64} # the amount of time jobs have been frozen
    parameters::NetworkParameters

    function NetworkState(parameters::NetworkParameters)
        L = parameters.L
        return new(zeros(Int,L), zeros(Bool, L), zeros(Float64, L),zeros(Float64, L), parameters)
    end
end