#+private
package game

import cont "containers"
import "physics"
import "render"
import rl "vendor:raylib"

PLAYER_AIM_HEIGHT :: 0.5

spawn_player :: proc() {
  e := spawn_at(Vec3(0))
  g.player.id = e.id

  e.kind |= {.Player}
  e.health = val(1)
  e.speed = val(200)

  g.player.weapon.ammo.current = 30
  g.player.weapon.ammo.max = 30
  g.player.weapon.fire.interval = 0.2
  g.player.weapon.reload.duration = 1.5
  g.player.weapon.reload.qte_start = 0.66
  g.player.weapon.reload.qte_duration = 0.075

  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 6, category = .Player)

  dir := at_random_angle()
  g.player.aim = to_vec3(dir * 2)
  physics.push(e.body, dir * 10)
}

spawn_player_base :: proc() {
  e := spawn_at(Vec3(0))
  e.kind |= {.Base}
  e.health = val(100)
  e.model = {
    kind = .Test,
  }
  physics.set_body_shape(&e.body, .Circle, 2, mass = 99999, category = .Obstacle)
}

reset_player :: proc() {
  g.player.inventory = Inventory{}
}

get_player :: proc() -> ^Entity {
  return cont.get(&g.entities, g.player.id)
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

  if g.player.weapon.fire.current > 0 {
    g.player.weapon.fire.current -= time.wdt
    return
  }

  can_shoot :=
    g.player.weapon.fire.current <= 0 &&
    g.player.weapon.ammo.current > 0 &&
    g.player.weapon.reload.current <= 0

  if can_shoot && rl.IsMouseButtonDown(.LEFT) {
    g.player.weapon.fire.current = g.player.weapon.fire.interval
    g.player.weapon.ammo.current -= 1
    target := g.player.aim
    position := e.transform.position
    speed := normalize(target - position) * PLAYER_BULLET_SPEED
    spawn_bullet(.Player, position, speed, e.crouch)
  }
}

player_reloading :: proc(e: ^Entity) {
  is_reloading := g.player.weapon.reload.current > 0
  can_reload := g.player.weapon.ammo.current < g.player.weapon.ammo.max && !is_reloading

  if is_reloading {
    g.player.weapon.reload.current += time.wdt

    is_reloading_done := weapon_is_reloading_done()
    is_in_qte_window := weapon_is_in_qte_window()

    if rl.IsKeyPressed(.E) {
      if is_in_qte_window && g.player.weapon.reload.can_qte {
        is_reloading_done = true
      } else {
        // TODO: qte failed
      }
      g.player.weapon.reload.can_qte = false
    }

    if is_reloading_done {
      g.player.weapon.reload.current = 0
      weapon_reload()
    }
  } else if can_reload && rl.IsKeyPressed(.E) {
    weapon_start_reload()
    g.player.weapon.reload.current += time.wdt
  }
}

player_camera_follow :: proc(e: ^Entity) {
  is_focus := !rl.IsMouseButtonDown(.RIGHT)
  if is_focus {
    camera_target := e.transform.position + g.player.aim
    render.move_camera_to(camera_target * 0.5)
  } else {
    camera_target := e.transform.position
    factor := f32(0.33)
    render.move_camera_to(camera_target * factor)
  }
}

