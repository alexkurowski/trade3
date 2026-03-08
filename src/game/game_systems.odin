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

    if .Player in e.kind do player_input(&e)
    update_transform(&e)
    // fall(&e)
    draw(&e)
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
    e.sprite.flip = true
  }
  if rl.IsKeyDown(.D) {
    input.x = 1
    e.sprite.flip = false
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

update_transform :: proc(e: ^Entity) {
  e.position = to_vec3(physics.get_position(e.body), e.position.y)
  e.velocity = to_vec3(physics.get_velocity(e.body), e.velocity.y)
}

// fall :: proc(e: ^Entity) {
//   if e.position.y <= 0 && e.velocity.y == 0 do return

//   e.position.y += e.velocity.y * time.dt
//   e.velocity.y -= 9.8 * time.dt

//   if e.position.y <= 0 {
//     e.position.y = 0
//     e.velocity.y = 0
//   }
// }

draw :: proc(e: ^Entity) {
  if e.sprite.kind != .None {
    render.sprite(e.sprite.kind, e.position, e.sprite.size, e.sprite.flip)
  }
}
