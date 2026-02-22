#+private
package game

import "deps:box"

EventPayload :: rawptr
EventCallback :: #type proc(data: EventPayload)

EventSubscriber :: struct {
  id:       ID,
  callback: EventCallback,
}

EventKind :: enum {
  None,
  Some,
}

SomeEvent :: struct {
  value: int,
}

@(private = "file")
subscribers: [EventKind]box.Array(EventSubscriber, ID, 32)
@(private = "file")
events: [EventKind]box.Pool(EventPayload, 1024)

subscribe :: proc(kind: EventKind, callback: proc(data: EventPayload)) -> (ID, bool) {
  return box.append(&subscribers[kind], EventSubscriber{callback = callback})
}

unsubscribe :: proc(kind: EventKind, id: ID) {
  box.remove(&subscribers[kind], id)
}

send_event :: proc(kind: EventKind, event: $T) {
  ptr := new_clone(event, context.temp_allocator)
  box.append(&events[kind], ptr)
}

process_events :: proc() {
  for kind in EventKind {
    for &event in box.every(&events[kind]) {
      for &subscriber in subscribers[kind].items {
        if box.is_none(subscriber) do continue
        subscriber.callback(event)
      }
    }
    box.clear(&events[kind])
  }
}

