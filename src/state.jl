#############################################################################
#############################################################################
#
# This file defines NetworkState, Customer, and NetworkStateCustomers.
#                                                                               
#############################################################################
#############################################################################

"""
An abstract type to represent the state of a simulation at a point in time.
"""
abstract type State end

"""
This mutable struct stores the state of a simulation, where we do NOT keep track
of individual customers.

    - queues stores the current number of jobs in each queue.
    - arrivals stores the total number of (both external and internal) 
        arrivals at each server.
    - server_status is a boolean vector representing whether the servers are on (1)
        or off (0).
    - the qth term of additional_times represents the time that a job was frozen 
        because the qth server was off. 
    - the qth term of last_off is a vector which stores the last time that the qth server 
        was off or started processing a new job.
"""
mutable struct NetworkState <: State
    queues::Vector{Int64} 
    arrivals::Vector{Int64} 
    server_status::Vector{Bool} 
    additional_times::Vector{Float64} 
    last_off::Vector{Float64} 
    parameters::NetworkParameters

    function NetworkState(parameters::NetworkParameters)
        L = parameters.L
        return new(zeros(Int, L), zeros(Int, L), ones(Bool, L),zeros(Float64, L), zeros(Float64, L), parameters)
    end
end

"""
This mutable struct represents a customer. The arrival time and departure time
are stored. If the customer has not left the network, then departure time is 
set to zero.
"""
mutable struct Customer
    arrival_time :: Float64
    departure_time :: Float64

    function Customer(arrival_time :: Float64)
        return new(arrival_time, 0)  # 0 is placeholder
    end
end

"""
This mutable struct stores the state of a simulation, where we keep track
of individual customers.

    - queues is a vector of queues which stores the customers lined up in each queue.
    - arrivals stores the total number of (both external and internal) 
        arrivals at each server.
    - server_status is a boolean vector representing whether the servers are on (1)
        or off (0).
    - the qth term of additional_times represents the time that a job was frozen 
        because the qth server was off. 
    - the qth term of last_off is a vector which stores the last time that the qth server 
        was off or started processing a new job.
"""
mutable struct NetworkStateCustomers <: State
    queues::Vector{Deque{Customer}} 
    arrivals::Vector{Int64} 
    server_status::Vector{Bool} 
    additional_times::Vector{Float64} 
    last_off::Vector{Float64} 
    parameters::NetworkParameters
    customers :: Set{Customer}

    function NetworkStateCustomers(parameters::NetworkParameters)
        L = parameters.L
        return new(
            [Deque{Customer}() for _ in 1:L],
            zeros(Int, L),
            ones(Bool, L),
            zeros(Float64, L),
            zeros(Float64, L),
            parameters,
            Set{Customer}())
    end
end


