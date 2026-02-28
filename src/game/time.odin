#+private
package game

import "core:math"
import rl "vendor:raylib"

time: struct {
  t:      f32, // Player total time
  wt:     f32, // World total time
  dt:     f32, // Delta time
  wdt:    f32, // World delta time
  factor: f32, // Delta to world delta factor
  target: f32, // Factor target
} = {
  factor = 0,
  target = 1,
}

time_step :: proc() {
  time.dt = math.min(rl.GetFrameTime(), 0.07)
  time.factor += (time.target - time.factor) * 2.5 * time.dt
  time.wdt = time.dt * time.factor
  time.t += time.dt
  time.wt += time.wdt
}

set_time_factor :: proc(f: f32) {
  time.target = f
}
