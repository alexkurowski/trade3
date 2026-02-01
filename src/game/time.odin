#+private
package game

import "core:math"
import rl "vendor:raylib"

time: struct {
  dt:     f32, // Delta time
  wdt:    f32, // World delta time
  factor: f32, // Delta to world delta factor
  target: f32, // Factor target
  wtc:    f32, // World turn countdown
} = {
  factor = 0,
  target = 1,
}

update_time :: proc() {
  time.dt = math.min(rl.GetFrameTime(), 0.07)
  time.factor += (time.target - time.factor) * 2.5 * time.dt
  time.wdt = time.dt * time.factor

  if time.wtc <= 0 {
    time.wtc += 1
  } else {
    time.wtc -= time.wdt
  }
}

set_time_factor :: proc(f: f32) {
  time.target = f
}

is_turn :: proc() -> bool {
  return time.wtc <= 0
}
