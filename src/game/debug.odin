#+private file
package game

import "./render"
import rl "vendor:raylib"

@(private)
debug_init :: proc() {
  subscribe(.Some, proc(e: rawptr) {
    e := cast(^SomeEvent)e
    p("Received event with value")
    p(e^)
    p(e.value)
  })
}

@(private)
debug_update :: proc() {
  if rl.IsKeyPressed(.SLASH) do g.debug_mode = !g.debug_mode
  if g.debug_mode {
    // render.shape(.DebugGrid, Vec3{100, 1, 0})
    render.sprite(.DebugFps, Vec2{0, 0})

    if rl.IsKeyPressed(.R) {
      start_new_game()
    }
  }
}

