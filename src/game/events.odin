#+private
package game

import cont "containers"

EventPayload :: rawptr
EventCallback :: #type proc(data: EventPayload)

EventSubscriber :: struct {
  id:       ID,
  callback: EventCallback,
}

EventKind :: enum {
  None,
  GotHurt,
  GotKilled,
}

SomeEvent :: struct {
  value: int,
}

@(private = "file")
subscribers: [EventKind]cont.Array(EventSubscriber, ID, 32)
@(private = "file")
events: [EventKind]cont.Pool(EventPayload, 1024)

subscribe :: proc(kind: EventKind, callback: proc(data: EventPayload)) -> (ID, bool) {
  return cont.append(&subscribers[kind], EventSubscriber{callback = callback})
}

unsubscribe :: proc(kind: EventKind, id: ID) {
  cont.remove(&subscribers[kind], id)
}

send_event :: proc(kind: EventKind, event: $T) {
  ptr := new_clone(event, context.temp_allocator)
  cont.append(&events[kind], ptr)
}

process_events :: proc() {
  for kind in EventKind {
    for &event in cont.every(&events[kind]) {
      for &subscriber in subscribers[kind].items {
        if cont.is_none(subscriber) do continue
        subscriber.callback(event)
      }
    }
    cont.clear(&events[kind])
  }
}

