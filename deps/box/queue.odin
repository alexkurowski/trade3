package box

Queue :: struct($T: typeid, $S: i32) {
  items: [S]T,
  count: i32,
  next:  i32,
}

append_queue :: proc(q: ^Queue($T, $S), value: T) -> ^T {
  if q.count < S {
    q.items[q.count] = value
    q.count += 1
    return &q.items[q.count - 1]
  }
  return nil
}

next :: proc(q: ^Queue($T, $S)) -> (^T, bool) {
  if q.next >= q.count {
    q.count = 0
    q.next = 0
    return nil, false
  }
  value := &q.items[q.next]
  q.next += 1
  return value, true
}

clear_queue :: proc(q: ^Queue($T, $S)) {
  q.count = 0
  q.next = 0
}

is_queue_full :: proc(q: ^Queue($T, $S)) -> bool {
  return q.count >= S
}

is_queue_empty :: proc(p: ^Queue($T, $S)) -> bool {
  return q.count == 0
}
