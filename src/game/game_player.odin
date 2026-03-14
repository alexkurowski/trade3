#+private
package game

import "core:math"
import "physics"
import "render"
import rl "vendor:raylib"

PLAYER_SPEED :: 200
PLAYER_LIMIT :: 20

player_controls :: proc(e: ^Entity) {
  player_movement(e)
  player_shooting(e)
}

player_movement :: proc(e: ^Entity) {
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

  if math.abs(e.transform.position.x) > PLAYER_LIMIT {
    input.x = sign(-e.transform.position.x)
  }
  if math.abs(e.transform.position.z) > PLAYER_LIMIT {
    input.y = sign(e.transform.position.z)
  }

  physics.push(e.body, render.to_camera_relative(input) * PLAYER_SPEED)
}

player_shooting :: proc(e: ^Entity) {
  @(static) player_shooting_cooldown: f32
  if player_shooting_cooldown > 0 {
    player_shooting_cooldown -= time.wdt
    return
  }

  if rl.IsMouseButtonDown(.LEFT) {
    player_shooting_cooldown = 0.2
    point := render.get_mouse_world_position()
    pos := e.transform.position
    dir := normalize(point - pos)
    spawn_bullet(pos, dir)
  }
}

player_camera_follow :: proc(e: ^Entity) {
  render.move_camera_to(e.transform.position / 3)
}

