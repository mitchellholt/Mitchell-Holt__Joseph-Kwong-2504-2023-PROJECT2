abstract type State end

mutable struct NetworkState <: State
    queues::Vector{Int64} # number of jobs in each queue
    arrivals::Vector{Int64} # total number of arrivals at each station over the simulation
    server_status::Vector{Bool} # whether servers are on or off
    parameters::NetworkParameters


    function NetworkState(parameters::NetworkParameters)
        L = parameters.L
        return new(zeros(Int, L), zeros(Int, L), ones(Bool, L), parameters)
    end
end

function show(state::NetworkState, time::Float64)
    println("time: \t\t $(time)")
    println("queues: \t $(state.queues)")
    println("servers: \t $(state.server_status)")
    println()
end
