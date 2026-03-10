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
  update_entities()

  physics.update(time.dt)
}


draw_map :: proc() {
  // Debug
  TILE_SIZE :: 2

  tile: Tile
  for i := 0; i <= int(g.current_location.size); i += 1 {
    for j := 0; j <= int(g.current_location.size); j += 1 {
      tile = g.current_location.tiles[i][j]
      switch tile.kind {
      case .None:
      // NOP
      case .Floor:
        height := f32(0.5)
        render.shape(
          .Cube,
          Vec3{f32(i * TILE_SIZE), -height / 2, f32(j * TILE_SIZE)},
          Vec3{1 * TILE_SIZE, height, 1 * TILE_SIZE},
          tile.color,
        )
      case .Wall:
        height := f32(2)
        render.shape(
          .Cube,
          Vec3{f32(i * TILE_SIZE), height / 2, f32(j * TILE_SIZE)},
          Vec3{1 * TILE_SIZE, height, 1 * TILE_SIZE},
          tile.color,
        )
      }
    }
  }
}

update_entities :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue

    if .Player in e.kind do player_input(&e)
    update_transform(&e)
    draw(&e)
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

  render.move_camera_to(e.transform.position)
}

update_transform :: proc(e: ^Entity) {
  t := physics.get_transform(e.body)
  e.transform.position = to_vec3(t.position, e.transform.position.y)
  e.transform.velocity = to_vec3(t.velocity, e.transform.velocity.y)
  e.transform.rotation = t.rotation
}

draw :: proc(e: ^Entity) {
  if e.sprite.kind != .None {
    render.sprite(e.sprite.kind, e.transform.position, e.sprite.size, e.sprite.flip)
  }
}
