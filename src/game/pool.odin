#+private
package game

Pool :: struct($S: int, $T: typeid) {
  data:  [S]T,
  count: int,
}

pool_append :: proc(p: ^Pool($S, $T), value: T) -> ^T {
  if p.count < S {
    p.data[p.count] = value
    p.count += 1
    return &p.data[p.count - 1]
  }
  return nil
}

pool_prepend :: proc(p: ^Pool($S, $T), value: T) {
  if p.count < S {
    for i: int = p.count; i > 0; i -= 1 {
      p.data[i] = p.data[i - 1]
    }
    p.data[0] = value
    p.count += 1
  }
}

pool_shift :: proc(p: ^Pool($S, $T)) -> T {
  if p.count == 0 do return T{}

  result: T = p.data[0]
  for i: int = 1; i < p.count; i += 1 {
    p.data[i - 1] = p.data[i]
  }
  p.count -= 1
  return result
}

pool_pop :: proc(p: ^Pool($S, $T)) -> T {
  if p.count == 0 do return T{}

  p.count -= 1
  return p.data[p.count]
}

// Make sure to iterate backwards when calling this
pool_remove :: proc(p: ^Pool($S, $T), idx: int) {
  if idx < p.count - 1 {
    p.data[idx] = p.data[p.count - 1]
  }
  p.count -= 1
}

pool_move_to_front :: proc(p: ^Pool($S, $T), idx: int) {
  if idx > 0 {
    temp: T = p.data[idx]
    for i := idx; i > 0; i -= 1 {
      p.data[i] = p.data[i - 1]
    }
    p.data[0] = temp
  }
}

pool_move_to_back :: proc(p: ^Pool($S, $T), idx: int) {
  if idx < p.count - 1 {
    temp: T = p.data[idx]
    for i := idx; i < p.count - 1; i += 1 {
      p.data[i] = p.data[i + 1]
    }
    p.data[p.count - 1] = temp
  }
}

pool_clear :: proc(p: ^Pool($S, $T)) {
  p.count = 0
}

pool_is_full :: proc(p: ^Pool($S, $T)) -> bool {
  return p.count >= S
}

pool_every :: proc(p: ^Pool($S, $T)) -> []T {
  return p.data[:p.count]
}

pool_first :: proc(p: ^Pool($S, $T)) -> ^T {
  if p.count == 0 do return nil
  return &p.data[0]
}

pool_last :: proc(p: ^Pool($S, $T)) -> ^T {
  if p.count == 0 do return nil
  return &p.data[p.count - 1]
}
