#############################################################################
#############################################################################
#
# This file implements events and how to process them.
#                                                                               
#############################################################################
#############################################################################

"""
An abstract type to represent all events that happen in the simulation.
"""
abstract type Event end

"""
The end of the simulation.
"""
struct EndSimEvent <: Event end

"""
A person arriving at the qth server.
"""
struct ArrivalEvent <: Event 
    q::Int
end

struct CustomerArrivalEvent <: Event 
    q :: Int
    customer :: Customer
end

"""
The qth server finishes serving a customer (if there are no breakdowns). 
"""
struct EndOfServiceEvent <: Event
    q::Int
end

"""
The qth server breaks down.
"""
struct ServerOffEvent <: Event 
    q::Int 
end

"""
The qth server is repaired.
"""
struct ServerOnEvent <: Event
    q::Int 
end


"""
A struct which consists of an event and a time stamp, which allows us 
to keep track of when events happen.
"""
struct TimedEvent
    event::Event
    time::Float64
end

"""
Compares two TimedEvents based on when they occur. This allows us to 
order TimedEvents.
"""
isless(te1::TimedEvent, te2::TimedEvent) = te1.time < te2.time

"""
This function returns a vector of TimedEvents, based on the state of the 
simulation at the current time, and the event being processed. 
"""
function process_event end

"""
Processes an EndSimEvent by doing nothing.
"""
function process_event(time::Float64, state::State, event::EndSimEvent)
    return TimedEvent[]
end

"""
Processes an external arrival at the qth server.
"""
function process_event(time::Float64, state::NetworkState, event::ArrivalEvent)
    q = event.q
    #@show q
    state.queues[q] += 1
    state.arrivals[q] += 1
    new_timed_events = [TimedEvent(ArrivalEvent(q), time + next_arrival_duration(state, q))]

    # we just added the only person to the queue, so they can start being served
    # now. Add an end of service event.
    if state.queues[q] == 1
        state.additional_times[q] = 0
        state.last_off[q] = time
        push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
    end
    return new_timed_events
end

function process_event(time::Float64, state::NetworkStateCustomers, event::CustomerArrivalEvent)
    q = event.q
    # check if customer is in state yet -- if not, add them
    # note that we only add customers to the set as they arrive in their first
    # queue so that the max_time state is accurate
    if !(event.customer in state.customers)
        push!(state.customers, event.customer)
    end
    push!(state.queues[q], event.customer)
    state.arrivals[q] += 1
    
    next_time = time + next_arrival_duration(state, q)
    new_timed_events = [
        TimedEvent(CustomerArrivalEvent(q, Customer(next_time)), next_time)
    ]

    if length(state.queues[q]) == 1
        # we just added the only person to the queue, so they can start being
        # served now. Add an end of service event.
        state.additional_times[q] = 0
        state.last_off[q] = time
        push!(new_timed_events,
            TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
    end
    return new_timed_events
end

"""
If there were no breakdowns during the service of this job 
(i.e. there is no additional time) then we process the end of a job at the qth server. 

If a breakdown occurred during service, then  we do nothing except spawn an 
endOfServiceEvent which is processed after the additional time has lapsed.
"""
function process_event(time::Float64, state::NetworkState, event::EndOfServiceEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    
    if state.additional_times[q] == 0
        state.queues[q] -= 1

        if state.queues[q] > 0
            push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
        end

        next_q = next_location(state, q)
        if next_q <= state.parameters.L
            state.queues[next_q] += 1
            state.arrivals[next_q] += 1

            if state.queues[next_q] == 1
                state.last_off[next_q] = time
                state.additional_times[next_q] = 0
                push!(new_timed_events, TimedEvent(EndOfServiceEvent(next_q), time + next_service_duration(state, next_q)))
            end
        end
    else
        push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + state.additional_times[q]))
        state.additional_times[q] = 0
        state.last_off[q] = time
    end

    return new_timed_events
end

function process_event(time::Float64, state::NetworkStateCustomers, event::EndOfServiceEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    
    if state.additional_times[q] == 0
        served_customer = popfirst!(state.queues[q])

        if length(state.queues[q]) > 0
            # start serving the next customer
            push!(new_timed_events,
                TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
        end

        next_q = next_location(state, q)
        if next_q <= state.parameters.L
            push!(state.queues[next_q], served_customer)
            state.arrivals[next_q] += 1

            if length(state.queues[next_q]) == 1
                state.last_off[next_q] = time
                state.additional_times[next_q] = 0
                push!(new_timed_events,
                    TimedEvent(EndOfServiceEvent(next_q), time + next_service_duration(state, next_q)))
            end
        else
            # Note the time the customer exits the system
            served_customer.departure_time = time
        end
    else
        push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + state.additional_times[q]))
        state.additional_times[q] = 0
        state.last_off[q] = time
    end

    return new_timed_events
end

"""
Processes a server breaking down. 
"""
function process_event(time::Float64, state::NetworkState, event::ServerOffEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = false
    state.last_off[q] = time

    push!(new_timed_events, TimedEvent(ServerOnEvent(q), time + next_on_duration(state)))
    return new_timed_events
end

"""
Processes a server repairing. 
"""
function process_event(time::Float64, state::State, event::ServerOnEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = true

    if state.queues[q] >= 1
        state.additional_times[q] = time - state.last_off[q]
    end

    push!(new_timed_events, TimedEvent(ServerOffEvent(q), time + next_off_duration(state)))
    return new_timed_events
end



