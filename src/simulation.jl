module GeneralizedUnreliableJacksonSim

import Base: isless
using StatsBase, Distributions, Random,DataStructures, LinearAlgebra, Accessors, Parameters
include("parameters.jl")
include("state.jl")
include("sampling.jl")
include("events.jl")



export NetworkParameters, NetworkState, next_location, sim_net, set_scenario, compute_lambda, compute_rho

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

end;
