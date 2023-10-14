
abstract type Event end

struct TimedEvent
    event::Event
    time::Float64
end

isless(te1::TimedEvent, te2::TimedEvent) = te1.time < te2.time

function process_event end

struct EndSimEvent <: Event end
struct LogStateEvent <: Event end

struct ArrivalEvent <: Event 
    q::Int 
end

struct ServerOffEvent <: Event 
    q::Int 
end

struct ServerOnEvent <: Event
    q::Int 
end


function process_event(time::Float64, state::State, es_event::EndSimEvent)
    println("Ending simulation at time $time.")
    return TimedEvent[]
end


function process_event(time::Float64, state::State, ls_event::LogStateEvent)
    println("Logging state at time $time.")
    println(state)
    return TimedEvent[]
end


function process_event(time::Float64, state::NetworkState, event::ArrivalEvent)
    q = event.q
    state.queues[q] += 1
    new_timed_events = TimedEvent[]

    push!(new_timed_events, TimedEvent(ArrivalEvent(q), time + next_arrival_duration(state, q)))

    if state.queues[q] == 1
        push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
    end
    return new_timed_events
end


function process_event(time::Float64, state::NetworkState, event::ServerOffEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = false
    state.last_off_times[q] = time

    push!(new_timed_events, TimedEvent(ServerOnEvent(q), time + next_on_duration(state)))
    return new_timed_events
end

function process_event(time::Float64, state::NetworkState, event::ServerOnEvent)
    q = event.q
    new_timed_events = TimedEvent[]
    state.server_status[q] = true

    if state.queues[q] > 0
        additional_time = time - state.last_off_times[q]
        state.additional_times[q] += additional_time 
    end

    push!(new_timed_events, TimedEvent(ServerOffEvent(q), time + next_off_duration(state)))
    return new_timed_events
end
 
struct EndOfServiceEvent <: Event
    q::Int 
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
            if state.queues[q] == 1
                push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + next_service_duration(state, q)))
            end
        end
    else 
        state.last_off_times[q] = time
        push!(new_timed_events, TimedEvent(EndOfServiceEvent(q), time + state.additional_times[q]))
    end

    return new_timed_events
end




































