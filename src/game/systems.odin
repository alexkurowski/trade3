#+private
package game

import "./physics"
import "deps:box"
import "render"
import rl "vendor:raylib"

process_systems :: proc() {
  time_step()
  physics.update(time.dt)

  for &e in g.entities.items {
    if box.is_none(e) do continue

    if rl.IsKeyDown(.A) {
      physics.push(e.body, Vec2{-100, 0})
    }
    if rl.IsKeyDown(.D) {
      physics.push(e.body, Vec2{100, 0})
    }
    if rl.IsKeyDown(.W) {
      physics.push(e.body, Vec2{0, -100})
    }
    if rl.IsKeyDown(.S) {
      physics.push(e.body, Vec2{0, 100})
    }

    e.position = to_vec3(physics.get_position(e.body), e.position.y)
    render.shape(.Sphere, e.position, e.body.size, {255, 255, 255, 255})
  }
}

