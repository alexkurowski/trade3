#+private
package game

import cont "containers"

EventQueue :: struct {
  subscribers: [EventKind]cont.Pool(EventCallback, 8),
  events:      [EventKind]cont.Pool(EventPayload, 1024),
}

EventPayload :: rawptr
EventCallback :: #type proc(data: EventPayload)

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

clear_all_events :: proc() {
  for kind in EventKind {
    cont.clear(&g.events.events[kind])
  }
}

//
//
//

EventKind :: enum {
  None,
  GotHurt,
  GotKilled,
}

subscribe_events :: proc() {
  subscribe :: proc(kind: EventKind, callback: EventCallback) {
    cont.append(&g.events.subscribers[kind], callback)
  }

  subscribe(.GotKilled, on_got_killed)
}

Event_Entity :: struct {
  id: ID,
}

on_got_killed :: proc(raw: EventPayload) {
  event := cast(^Event_Entity)raw
  entity := cont.get(&g.entities, event.id)
  if entity != nil {
    despawn(entity.id)
  }
}

