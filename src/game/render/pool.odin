package render

Pool :: struct($T: typeid, $S: i32) {
  items: [S]T,
  count: i32,
}

push :: proc(p: ^Pool($T, $S), value: T) -> ^T {
  if p.count < S {
    p.items[p.count] = value
    p.count += 1
    return &p.items[p.count - 1]
  }
  return nil
}

every :: proc(p: ^Pool($T, $S)) -> []T {
  return p.items[:p.count]
}

// Make sure to iterate backwards when calling this
remove_pool :: proc(p: ^Pool($T, $S), idx: i32) {
  if idx < p.count - 1 {
    p.items[idx] = p.items[p.count - 1]
  }
  p.count -= 1
}

clear_pool :: proc(p: ^Pool($T, $S)) {
  p.count = 0
}

move_to_front :: proc(p: ^Pool($T, $S), idx: i32) {
  if idx > 0 {
    temp: T = p.items[idx]
    for i := idx; i > 0; i -= 1 {
      p.items[i] = p.items[i - 1]
    }
    p.items[0] = temp
  }
}

move_to_back :: proc(p: ^Pool($T, $S), idx: i32) {
  if idx < p.count - 1 {
    temp: T = p.items[idx]
    for i := idx; i < p.count - 1; i += 1 {
      p.items[i] = p.items[i + 1]
    }
    p.items[p.count - 1] = temp
  }
}

