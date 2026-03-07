#+private
package game

import "deps:box"
import "physics"
import "render"
import rl "vendor:raylib"

process_systems :: proc() {
  time_step()
  physics.update(time.dt)

  for &e in g.entities.items {
    if box.is_none(e) do continue

    if e.kind == .Player {
      player_input(&e)
    }

    e.position = to_vec3(physics.get_position(e.body), e.position.y)
    // render.shape(.Sphere, e.position, e.body.size, {255, 255, 255, 255})
  }
}

@(private = "file")
player_input :: proc(e: ^Entity) {
  input: Vec2
  if rl.IsKeyDown(.A) {
    input.x = -1
  }
  if rl.IsKeyDown(.D) {
    input.x = 1
  }
  if rl.IsKeyDown(.W) {
    input.y = 1
  }
  if rl.IsKeyDown(.S) {
    input.y = -1
  }
  physics.push(e.body, render.to_camera_relative(input) * 100)
}

