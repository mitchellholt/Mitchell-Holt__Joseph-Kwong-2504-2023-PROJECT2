abstract type Event end

struct TimedEvent
    event::Event
    time::Float64
end

isless(te1::TimedEvent, te2::TimedEvent) = te1.time < te2.time

function process_event end

struct EndSimEvent <: Event end

# In each of the following, q is the station number relevant to the event
struct ArrivalEvent <: Event 
    q::Int
end

struct EndOfServiceEvent <: Event
    q::Int
end

struct CustomerArrivalEvent <: Event 
    q :: Int
    customer :: Customer
end

struct ServerOffEvent <: Event 
    q::Int 
end

struct ServerOnEvent <: Event
    q::Int 
end


function process_event(time::Float64, state::State, es_event::EndSimEvent)
    #println("Ending simulation at time $time.")
    return TimedEvent[]
end

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
    state.queues[q].push!(event.customer)
    state.arrivals[q] += 1
    
    next_time = time + next_arrival_duration(state, q)
    new_timed_events = [
        TimedEvent(CustomerArrivalEvent(q, Customer(next_time)), next_time)
    ]

    if state.queues[q] == 1
        # we just added the only person to the queue, so they can start being
        # served now. Add an end of service event.
        state.additional_times[q] = 0
        state.last_off[q] = time
        push!(new_timed_events,
            TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
    end
    return new_timed_events
end


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

        if state.queues[q] > 0
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


function process_event(time::Float64, state::NetworkState, event::ServerOffEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = false
    state.last_off[q] = time

    push!(new_timed_events, TimedEvent(ServerOnEvent(q), time + next_on_duration(state)))
    return new_timed_events
end

function process_event(time::Float64, state::NetworkState, event::ServerOnEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = true

    if state.queues[q] >= 1
        state.additional_times[q] = time - state.last_off[q]
    end

    push!(new_timed_events, TimedEvent(ServerOffEvent(q), time + next_off_duration(state)))
    return new_timed_events
end
