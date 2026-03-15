#+private
package game

import cont "containers"

EventQueue :: struct {
  subscribers: [EventKind]cont.Pool(EventCallback, 8),
  events:      [EventKind]cont.Pool(EventPayload, 1024),
}

EventPayload :: rawptr
EventCallback :: #type proc(data: EventPayload)

EventKind :: enum {
  None,
  GotHurt,
  GotKilled,
}

send_event :: proc(kind: EventKind, event: $T) {
  ptr := new_clone(event, context.temp_allocator)
  cont.append(&g.events.events[kind], ptr)
}

process_events :: proc() {
  for kind in EventKind {
    for &event in cont.every(&g.events.events[kind]) {
      for &subscriber in cont.every(&g.events.subscribers[kind]) {
        subscriber(event)
      }
    }
    cont.clear(&g.events.events[kind])
  }
}

//
//
//

subscribe_events :: proc() {
  cont.append(&g.events.subscribers[.GotKilled], on_got_killed)
}

Event_Entity :: struct {
  id: ID,
}

on_got_killed :: proc(raw: EventPayload) {
  p(raw)
  event := cast(^Event_Entity)raw
  p(event)
  entity := cont.get(&g.entities, event.id)
  if entity == nil do return
  despawn(entity.id)
}

