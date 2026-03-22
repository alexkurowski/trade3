#+private
package game

import "core:math"
import "physics"
import "render"
import rl "vendor:raylib"

player_controls :: proc(e: ^Entity) {
  player_movement(e)
  player_shooting(e)
  player_reloading(e)
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

  if rl.IsKeyPressed(.C) {
    e.crouch = !e.crouch
  }

  speed := e.speed.current
  if e.crouch {
    speed *= 0.66
  }
  physics.push(e.body, render.to_camera_relative(input) * speed)
}

player_shooting :: proc(e: ^Entity) {
  PLAYER_BULLET_SPEED :: 40

  @(static) player_shooting_cooldown: f32
  if player_shooting_cooldown > 0 {
    player_shooting_cooldown -= time.wdt
    return
  }

  can_shoot := player_shooting_cooldown <= 0 && e.weapon.ammo.current > 0

  if rl.IsMouseButtonDown(.LEFT) && can_shoot {
    player_shooting_cooldown = 0.2
    e.weapon.ammo.current -= 1
    target := g.player_aim
    position := e.transform.position
    speed := normalize(target - position) * PLAYER_BULLET_SPEED
    spawn_bullet(.Player, position, speed, e.crouch)
  }
}

player_reloading :: proc(e: ^Entity) {
  if rl.IsKeyPressed(.E) {
    weapon_reload(&e.weapon)
  }
}

player_camera_follow :: proc(e: ^Entity) {
  is_focus := !rl.IsMouseButtonDown(.RIGHT)
  if is_focus {
    camera_target := e.transform.position + g.player_aim
    render.move_camera_to(camera_target * 0.5)
  } else {
    camera_target := e.transform.position
    factor := f32(0.33)
    render.move_camera_to(camera_target * factor)
  }
}

