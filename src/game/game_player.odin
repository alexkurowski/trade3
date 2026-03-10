#+private
package game

import "physics"
import "render"
import rl "vendor:raylib"

player_controls :: proc(e: ^Entity) {
  PLAYER_SPEED :: 200

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
  physics.push(e.body, render.to_camera_relative(input) * PLAYER_SPEED)
}

player_camera_follow :: proc(e: ^Entity) {
  render.move_camera_to(e.transform.position)
}
