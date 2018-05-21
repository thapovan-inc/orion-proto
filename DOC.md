# Overview

The protocol takes two assumptions. Every user action is a `Trace`. Every `Trace` spans across different computational contexts. The computational context can be a _service_, a _class_ or a _method_. Each context is represented by a `Span`. Individual spans can report multiple events. Though events can be of many types, for the sake of simplicity we broadly classify the events as `StartEvent`, `StopEvent` and `LogEvent`.

`StartEvent` denotes start of a span, `StopEvent` denotes end of a span and `LogEvent` denotes any other event that is emitted during the lifetime of the span.

Each of the event carries optional `metadata` and mandatory `event_id`


## Trace

```protobuf
message Trace {
    string trace_id = 1;
}
```

A trace is denoted by a `trace_id` which must be a [UUID v4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)).

A trace by itself is of little help. Hence the `Trace` context is always represented and reported with a `Span` context. 

## Span

```protobuf
message Span {
    Trace trace_context = 1;
    string span_id = 2;
    oneof event {
        StartEvent start_event = 3;
        EndEvent end_event = 4;
        LogEvent log_event = 5;
    }
    uint64 timestamp  = 6;
    string service_name = 7;
    string event_location = 8;
    string parent_span_id = 9;
}
```

The `Span` message/class actually denotes an event from the span's lifecycle. Meaning, when a `Span` object is sent to the server, it is always accompanied by an event and only one event is allowed per `Span` message.

A span is uniquely identified by a combination of its `Trace` context and a `span_id` (UUID v4). Optionally, where available the `parent_span_id` can be mentioned to denote that the current span is a child of another span within the same trace context.

Each span message is timestamped by the producer (the entity which emits the span message) and the `timestamp` is denoted an unsigned 64-bit integer representing the UTC time in microsecond. In platforms where microsecond precision is not available or not plausible due to performance constraints the microsecond part of the integer (last 3 digits) can be set to zero. This sets the minimum acceptable precision to be milliseconds.

The `event` field can store either a `StartEvent`, an `EndEvent` or a `LogEvent`. The structure of these event messages are explained in the following sections.

The field `service_name` is a string which denotes the canonical name of the computational context denoted by the span. By convention, this is the process/server through which the request gets processed.

The field `location` is a string which denotes the code location within which the event is being emitted. In class oriented languages this can be of the form `ClassName::methodName::line_number`. Depending on the language support and convention, this can also be of the form `Filename::line_number`. 

## StartEvent
