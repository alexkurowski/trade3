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

  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 6, category = .Player)

  g.player.aim.position = to_vec3(at_random_angle()) * 2
  g.player.aim.show_last_timeout = -1
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

  if g.debug {
    // DEBUG
    from := e.transform.position
    to := g.player.aim.position

    to1 := to
    rotate_vec3(&to1, g.player.weapon.spray.current * DEG_TO_RAD)
    to1 = to1 + (to1 - from) * 20

    to2 := to
    rotate_vec3(&to2, -g.player.weapon.spray.current * DEG_TO_RAD)
    to2 = to2 + (to2 - from) * 20

    render.shape(.Line, from, to1, rl.RED)
    render.shape(.Line, from, to2, rl.RED)
    render.shape(.CircleY, g.player.aim.position, g.player.aim.world_radius)
  }
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
  should_shoot := can_shoot && rl.IsMouseButtonDown(.LEFT)

  if should_shoot {
    g.player.weapon.fire.current = g.player.weapon.fire.interval

    aim_screen_position := render.get_screen_position(g.player.aim.position)
    aim_screen_position += at_random_angle(randf(0, g.player.aim.screen_radius))
    aim_world_position := render.get_world_position(aim_screen_position)
    player_world_position := e.transform.position

    direction := normalize(aim_world_position - player_world_position)
    speed := direction * PLAYER_BULLET_SPEED
    spawn_bullet(.Player, player_world_position, speed, e.crouch)

    g.player.weapon.ammo.current -= 1
    g.player.aim.last_shot = aim_world_position
    g.player.aim.show_last_timeout = 0.33
  }

  if should_shoot {
    if g.player.weapon.spray.current < g.player.weapon.spray.max {
      g.player.weapon.spray.current += g.player.weapon.spray.max / 10
    }
  } else {
    if g.player.weapon.spray.current > g.player.weapon.spray.min {
      g.player.weapon.spray.current -= 20 * time.wdt
    }
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
    camera_target := e.transform.position + g.player.aim.position
    render.move_camera_to(camera_target * 0.5)
  } else {
    camera_target := e.transform.position
    factor := f32(0.33)
    render.move_camera_to(camera_target * factor)
  }
}

