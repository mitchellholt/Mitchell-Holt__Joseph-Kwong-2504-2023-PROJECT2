#############################################################################
#############################################################################
#
# This file defines the module GeneralizedUnreliableJacksonSim, and 
# implements the main simulation loops.
#                                                                               
#############################################################################
#############################################################################

module GeneralizedUnreliableJacksonSim

import Base: isless
using StatsBase, Distributions, Random,DataStructures, LinearAlgebra, Accessors, Parameters

include("parameters.jl")
include("state.jl")
include("sampling.jl")
include("events.jl")

export NetworkParameters, NetworkState, NetworkStateCustomers, next_location, sim_net, sim_net_customers, set_scenario, compute_lambda, compute_rho

"""
Simulates a generalised unreliable Jackson network with given parameters.

This simulation does NOT keep track of individual customers.
"""
function sim_net(parameters::NetworkParameters; state = NetworkState(parameters),
        max_time = 10^6, warm_up_time = 10^4, seed::Int64 = 42,
        callback = (_, _) -> nothing)

    Random.seed!(seed)

    timed_event_heap = BinaryMinHeap{TimedEvent}()

    push!(timed_event_heap, TimedEvent(EndSimEvent(), max_time))

    for q in 1:parameters.L 
        if parameters.alpha_vector[q] > 0 
            push!(timed_event_heap, TimedEvent(ArrivalEvent(q), next_arrival_duration(state, q)))
        end

        if parameters.gamma_1 > 0
            push!(timed_event_heap, TimedEvent(ServerOffEvent(q), next_off_duration(state)))
        end
    end

    time = 0.0

    callback(state, time)

    while true
        timed_event = pop!(timed_event_heap)
        time = timed_event.time
        new_timed_events = process_event(time, state, timed_event.event)
        
        callback(state, time)

        isa(timed_event.event, EndSimEvent) && break

        for nte in new_timed_events
            push!(timed_event_heap, nte)
        end     
    end
end

"""
Simulates a generalised unreliable Jackson network with given parameters.

This simulation keeps track of individual customers.
"""
function sim_net_customers(parameters :: NetworkParameters;
        state = NetworkStateCustomers(parameters),
        max_time = 10^6, warm_up_time = 10^4, seed::Int64 = 42)

    Random.seed!(seed)

    timed_event_heap = BinaryMinHeap{TimedEvent}()

    push!(timed_event_heap, TimedEvent(EndSimEvent(), max_time))

    for q in 1:parameters.L 
        if parameters.alpha_vector[q] > 0 
            next_time = next_arrival_duration(state, q)
            push!(timed_event_heap,
                TimedEvent(CustomerArrivalEvent(q, Customer(next_time)), next_time))
        end

        if parameters.gamma_1 > 0
            push!(timed_event_heap,
                TimedEvent(ServerOffEvent(q), next_off_duration(state)))
        end
    end

    time = 0.0

    while true
        timed_event = pop!(timed_event_heap)
        time = timed_event.time
        new_timed_events = process_event(time, state, timed_event.event)
        
        isa(timed_event.event, EndSimEvent) && break

        for nte in new_timed_events
            push!(timed_event_heap, nte)
        end
    end

    return state
end

end;
