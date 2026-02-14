package box

Pool :: struct($T: typeid, $S: i32) {
  items: [S]T,
  count: i32,
}

append_pool :: proc(p: ^Pool($T, $S), value: T) -> ^T {
  if p.count < S {
    p.items[p.count] = value
    p.count += 1
    return &p.items[p.count - 1]
  }
  return nil
}

prepend :: proc(p: ^Pool($T, $S), value: T) {
  if p.count < S {
    for i: i32 = p.count; i > 0; i -= 1 {
      p.items[i] = p.items[i - 1]
    }
    p.items[0] = value
    p.count += 1
  }
}

shift :: proc(p: ^Pool($T, $S)) -> T {
  if p.count == 0 do return T{}

  result: T = p.items[0]
  for i: i32 = 1; i < p.count; i += 1 {
    p.items[i - 1] = p.items[i]
  }
  p.count -= 1
  return result
}

pop :: proc(p: ^Pool($T, $S)) -> T {
  if p.count == 0 do return T{}

  p.count -= 1
  return p.items[p.count]
}

// Make sure to iterate backwards when calling this
remove_pool :: proc(p: ^Pool($T, $S), idx: i32) {
  if idx < p.count - 1 {
    p.items[idx] = p.items[p.count - 1]
  }
  p.count -= 1
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

clear_pool :: proc(p: ^Pool($T, $S)) {
  p.count = 0
}

is_full :: proc(p: ^Pool($T, $S)) -> bool {
  return p.count >= S
}

every :: proc(p: ^Pool($T, $S)) -> []T {
  return p.items[:p.count]
}

first :: proc(p: ^Pool($T, $S)) -> ^T {
  if p.count == 0 do return nil
  return &p.items[0]
}

last :: proc(p: ^Pool($T, $S)) -> ^T {
  if p.count == 0 do return nil
  return &p.items[p.count - 1]
}
