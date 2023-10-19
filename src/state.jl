abstract type State end

mutable struct NetworkState <: State
    queues::Vector{Int64} # number of jobs in each queue
    arrivals::Vector{Int64} # total number of arrivals at each station over the simulation
    server_status::Vector{Bool} # whether servers are on or off
    additional_times::Vector{Float64} 
    last_off::Vector{Float64} 
    parameters::NetworkParameters


    function NetworkState(parameters::NetworkParameters)
        L = parameters.L
        return new(zeros(Int, L), zeros(Int, L), ones(Bool, L),zeros(Float64, L), zeros(Float64, L), parameters)
    end
end

function show(state::NetworkState, time::Float64)
    println()
    println("time: \t\t $(time)")
    println("queues: \t $(state.queues)")
end


mutable struct Customer
    arrival_time :: Float64
    departure_time :: Float64

    function Customer(arrival_time :: Float64)
        return new(arrival_time, 0)  # 0 is placeholder
    end
end


mutable struct NetworkStateCustomers <: State
    queues::Vector{Queue{Customer}} # customers in each queue
    arrivals::Vector{Int64} # total number of arrivals at each station over the simulation
    server_status::Vector{Bool} # whether servers are on or off
    additional_times::Vector{Float64} 
    last_off::Vector{Float64} 
    parameters::NetworkParameters
    customers :: Set{Customer}

    function NetworkState(parameters::NetworkParameters)
        L = parameters.L
        return new(
            [Queue{Customer}() for _ in 1:L],
            zeros(Int, L),
            ones(Bool, L),
            zeros(Float64, L),
            zeros(Float64, L),
            parameters,
            Set{Customer}())
    end
end

function show(state::NetworkState, time::Float64)
    println()
    println("time: \t\t $(time)")
    println("queues: \t $(state.queues)")
end
