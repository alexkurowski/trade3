#+private
package game

import cont "containers"
import "physics"
import "render"
import rl "vendor:raylib"

PLAYER_RADIUS :: 0.75
PLAYER_AIM_HEIGHT :: 0.5

Player :: struct {
  id:            ID,
  aim:           struct {
    position:          Vec3,
    last_shot:         Vec3,
    show_last_timeout: f32,
    world_radius:      f32,
    screen_radius:     f32,
  },
  mouse:         Vec2,
  weapon:        PlayerWeapon,
  inventory:     Inventory,
  pickup_radius: f32,
}

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
  e.radius = PLAYER_RADIUS
  physics.set_body_shape(&e.body, .Circle, e.radius, mass = 6, category = .Player)

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
  player_aiming(e)
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

  if length(input) > 0.5 {
    weapon_sway_prolong()
  }
}

player_aiming :: proc(e: ^Entity) {
  g.player.mouse = render.get_screen_position(g.player.aim.position)
  g.player.mouse += rl.GetMouseDelta()

  g.player.aim.position = render.get_world_position(g.player.mouse)
  g.player.aim.world_radius = get_weapon_aim_radius(e.transform.position)

  aim_world_circle_point := g.player.aim.position
  aim_world_circle_point.x += g.player.aim.world_radius

  g.player.aim.screen_radius = length(
    g.player.mouse - render.get_screen_position(aim_world_circle_point),
  )

  weapon_sway_decrease()
}

player_shooting :: proc(e: ^Entity) {
  PLAYER_BULLET_SPEED :: 40

  if g.player.weapon.fire.current > 0 {
    g.player.weapon.fire.current -= time.wdt
    return
  }

  can_shoot :=
    g.player.weapon.fire.current <= 0 &&
    g.player.weapon.clip.current > 0 &&
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

    weapon_sway_increase()

    g.player.weapon.clip.current -= 1
    g.player.aim.last_shot = aim_world_position
    g.player.aim.show_last_timeout = 0.33
  }
}

player_reloading :: proc(e: ^Entity) {
  is_reloading := g.player.weapon.reload.current > 0
  can_reload := !is_reloading && g.player.weapon.clip.current < g.player.weapon.clip.max

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
