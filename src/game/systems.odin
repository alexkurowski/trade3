#+private file
package game

import "deps:box"
import "physics"
import "render"
import rl "vendor:raylib"

@(private)
process_systems :: proc() {
  time_step()

  draw_map()

  for &e in g.entities.items {
    if box.is_none(e) do continue

    if e.kind == .Player {
      player_input(&e)
    }

    e.position = to_vec3(physics.get_position(e.body), e.position.y)
    // render.shape(.Sphere, e.position, e.body.size, {255, 255, 255, 255})
  }

  physics.update(time.dt)
}

draw_map :: proc() {
  // Debug
  TILE_SIZE :: 2

  for i := -5; i <= 5; i += 1 {
    for j := -5; j <= 5; j += 1 {
      render.shape(
        .Cube,
        Vec3{f32(i * TILE_SIZE), -0.5, f32(j * TILE_SIZE)},
        Vec3{0.7 * TILE_SIZE, 0.5, 0.7 * TILE_SIZE},
        {40, 200, 100, 255},
      )
    }
  }
}

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

  render.move_camera_to(e.position)
}

