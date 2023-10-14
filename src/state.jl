
abstract type State end

mutable struct NetworkState <: State 
    queues::Vector{Int64} # number of jobs in each queue
    server_status::Vector{Bool} # whether servers are on or off
    additional_times::Vector{Int64} # the amount of time jobs have been frozen
    parameters::NetworkParameters
end