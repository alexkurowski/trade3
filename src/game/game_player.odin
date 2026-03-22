#+private
package game

import "core:math"
import "physics"
import "render"
import rl "vendor:raylib"

spawn_player :: proc() {
  e := spawn_at(Vec3(0))
  e.kind |= {.Player}
  e.health = val(10)
  e.speed = val(200)
  weapon_set_ammo(&e.weapon, 30)
  e.weapon.fire.interval = 0.2
  e.weapon.reload.duration = 1.5
  e.weapon.reload.qte_start = 0.66
  e.weapon.reload.qte_duration = 0.075
  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 6, category = .Player)
  g.player_id = e.id
  g.player_aim = Vec3(0)
}

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

  if e.weapon.fire.current > 0 {
    e.weapon.fire.current -= time.wdt
    return
  }

  can_shoot :=
    e.weapon.fire.current <= 0 && e.weapon.ammo.current > 0 && e.weapon.reload.current <= 0

  if can_shoot && rl.IsMouseButtonDown(.LEFT) {
    e.weapon.fire.current = e.weapon.fire.interval
    e.weapon.ammo.current -= 1
    target := g.player_aim
    position := e.transform.position
    speed := normalize(target - position) * PLAYER_BULLET_SPEED
    spawn_bullet(.Player, position, speed, e.crouch)
  }
}

player_reloading :: proc(e: ^Entity) {
  is_reloading := e.weapon.reload.current > 0
  can_reload := e.weapon.ammo.current < e.weapon.ammo.max && !is_reloading

  if is_reloading {
    e.weapon.reload.current += time.wdt

    is_reloading_done := weapon_is_reloading_done(&e.weapon)
    is_in_qte_window := weapon_is_in_qte_window(&e.weapon)

    if rl.IsKeyPressed(.E) {
      if is_in_qte_window && e.weapon.reload.can_qte {
        is_reloading_done = true
      } else {
        // TODO: qte failed
      }
      e.weapon.reload.can_qte = false
    }

    if is_reloading_done {
      e.weapon.reload.current = 0
      weapon_reload(&e.weapon)
    }
  } else if can_reload && rl.IsKeyPressed(.E) {
    weapon_start_reload(&e.weapon)
    e.weapon.reload.current += time.wdt
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

