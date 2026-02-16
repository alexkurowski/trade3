package text

import "core:fmt"
import "core:math"
import "core:strings"


@(private)
b: strings.Builder

@(private)
not := map[string]bool{}


load :: proc() {
  b = strings.builder_make(0xFF)
}

make_random_name :: proc() -> string {
  strings.builder_reset(&b)
  build_random_name()
  capitalize()
  return strings.clone(strings.to_string(b))
}

make_random_full_name :: proc() -> string {
  strings.builder_reset(&b)
  build_random_name()
  capitalize()
  strings.write_string(&b, " ")
  last_name_idx := len(b.buf)
  build_random_name()
  capitalize(last_name_idx)
  return strings.clone(strings.to_string(b))
}

make_faction_name :: proc() -> string {
  strings.builder_reset(&b)
  clear(&not)

  syllable_count := rand_bellcurve(2, 4, 2)
  for i: i32 = 0; i < syllable_count; i += 1 {
    syllable := rand_choice(name_a[:], &not)
    not[syllable] = true
    strings.write_string(&b, syllable)
  }
  strings.write_string(&b, rand_choice(faction_name_suffix[:]))
  capitalize()

  return strings.clone(strings.to_string(b))
}

make_ship_callsign :: proc() -> string {
  id := [7]byte{}

  id[0] = rand_choice(letters[:])
  id[1] = rand_choice(numbers[:])
  id[2] = rand_choice(chance(0.3) ? letters[:] : numbers[:])
  id[3] = '-'
  id[4] = rand_choice(chance(0.5) ? letters[:] : numbers[:])
  id[5] = rand_choice(chance(0.7) ? letters[:] : numbers[:])
  id[6] = rand_choice(chance(0.9) ? letters[:] : numbers[:])

  return strings.clone_from_bytes(id[:])
}

format_number :: proc(amount: $T) -> string where IS_NUMERIC(T) {
  if amount >= 1_000_000_000 {
    return fmt.tprintf("%.2fB", amount / 1_000_000_000)
  } else if amount >= 1_000_000 {
    return fmt.tprintf("%.2fM", amount / 1_000_000)
  } else if amount >= 1_000 {
    return fmt.tprintf("%.2fk", amount / 1_000)
  } else {
    return fmt.tprintf("%.0f", math.floor(amount))
  }
}

format_money :: proc(amount: $T) -> string where IS_NUMERIC(T) {
  if amount >= 1_000_000_000 {
    return fmt.tprintf("$%.2fB", amount / 1_000_000_000)
  } else if amount >= 1_000_000 {
    return fmt.tprintf("$%.2fM", amount / 1_000_000)
  } else if amount >= 1_000 {
    return fmt.tprintf("$%.2fk", amount / 1_000)
  } else {
    return fmt.tprintf("$%.0f", math.floor(amount))
  }
}
