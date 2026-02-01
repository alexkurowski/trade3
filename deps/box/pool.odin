package box

Pool :: struct($T: typeid, $S: int) {
  data:  [S]T,
  count: int,
}

append_pool :: proc(p: ^Pool($T, $S), value: T) -> ^T {
  if p.count < S {
    p.data[p.count] = value
    p.count += 1
    return &p.data[p.count - 1]
  }
  return nil
}

prepend :: proc(p: ^Pool($T, $S), value: T) {
  if p.count < S {
    for i: int = p.count; i > 0; i -= 1 {
      p.data[i] = p.data[i - 1]
    }
    p.data[0] = value
    p.count += 1
  }
}

shift :: proc(p: ^Pool($T, $S)) -> T {
  if p.count == 0 do return T{}

  result: T = p.data[0]
  for i: int = 1; i < p.count; i += 1 {
    p.data[i - 1] = p.data[i]
  }
  p.count -= 1
  return result
}

pop :: proc(p: ^Pool($T, $S)) -> T {
  if p.count == 0 do return T{}

  p.count -= 1
  return p.data[p.count]
}

// Make sure to iterate backwards when calling this
remove_pool :: proc(p: ^Pool($T, $S), idx: int) {
  if idx < p.count - 1 {
    p.data[idx] = p.data[p.count - 1]
  }
  p.count -= 1
}

move_to_front :: proc(p: ^Pool($T, $S), idx: int) {
  if idx > 0 {
    temp: T = p.data[idx]
    for i := idx; i > 0; i -= 1 {
      p.data[i] = p.data[i - 1]
    }
    p.data[0] = temp
  }
}

move_to_back :: proc(p: ^Pool($T, $S), idx: int) {
  if idx < p.count - 1 {
    temp: T = p.data[idx]
    for i := idx; i < p.count - 1; i += 1 {
      p.data[i] = p.data[i + 1]
    }
    p.data[p.count - 1] = temp
  }
}

clear_pool :: proc(p: ^Pool($T, $S)) {
  p.count = 0
}

is_full :: proc(p: ^Pool($T, $S)) -> bool {
  return p.count >= S
}

every :: proc(p: ^Pool($T, $S)) -> []T {
  return p.data[:p.count]
}

first :: proc(p: ^Pool($T, $S)) -> ^T {
  if p.count == 0 do return nil
  return &p.data[0]
}

last :: proc(p: ^Pool($T, $S)) -> ^T {
  if p.count == 0 do return nil
  return &p.data[p.count - 1]
}
