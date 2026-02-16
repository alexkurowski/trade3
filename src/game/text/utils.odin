#+private
package text

import "core:math/rand"
import "core:strings"
import "core:unicode"

build_random_name :: proc() {
  clear(&not)

  variant := rand.int32_range(0, 4)
  if variant == 0 {
    syllable_count := rand_bellcurve(1, 4, 3)
    for i: i32 = 0; i < syllable_count; i += 1 {
      syllable := rand_choice(name_a[:], &not)
      not[syllable] = true
      strings.write_string(&b, syllable)
    }
  } else if variant == 1 {
    syllable_count := rand_bellcurve(1, 4, 4)
    for i: i32 = 0; i < syllable_count; i += 1 {
      syllable := rand_choice(name_b[:], &not)
      not[syllable] = true
      strings.write_string(&b, syllable)
    }
  } else if variant == 2 {
    syllable_count := rand_bellcurve(1, 4, 3)
    for i: i32 = 0; i < syllable_count; i += 1 {
      strings.write_string(&b, rand_choice(name_a[:]))
    }
  } else if variant == 3 {
    syllable_count := rand_bellcurve(1, 4, 4)
    for i: i32 = 0; i < syllable_count; i += 1 {
      strings.write_string(&b, rand_choice(name_b[:]))
    }
  } else {
    unreachable()
  }
}

capitalize :: proc(idx: int = 0) {
  b.buf[idx] = byte(unicode.to_upper(rune(b.buf[idx])))
}

chance :: proc(percentage: f32) -> bool {
  return rand.float32() < percentage
}

rand_bellcurve :: proc(min, max, bell_curve: i32) -> i32 {
  total: i32 = 0
  for i := i32(0); i < bell_curve; i += 1 {
    total += rand.int32_range(min, max + 1)
  }
  return total / bell_curve
}

rand_choice_any :: proc(arr: []$T) -> T {
  return rand.choice(arr)
}
rand_choice_not :: proc(arr: []$T, not: ^map[T]bool) -> T {
  for {
    out := rand.choice(arr)
    if not == nil {
      return out
    }
    if _, found := not[out]; !found {
      return out
    }
  }
}
rand_choice :: proc {
  rand_choice_any,
  rand_choice_not,
}
