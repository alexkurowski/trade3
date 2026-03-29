#+private
package game

import "physics"
import "render"

spawn_enemy :: proc() {
  DIFFICULTY: struct {
    health: f32,
    speed:  f32,
  } : {health = 0.5, speed = 0.1}

  position := g.location.doors[randi(0, 1)]
  e := spawn_at(position + rand_offset(0, TILE_SIZE / 2))
  e.kind = {.Enemy}
  e.health = val(1 + DIFFICULTY.speed * g.round_age)
  e.speed = val(10 + DIFFICULTY.speed * g.round_age)
  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 2, category = .Enemy)
}

enemy_controls :: proc(e: ^Entity) {
  enemy_move(e)
  enemy_attack(e)
}

enemy_move :: proc(e: ^Entity) {
  player := get_player()
  if player == nil do return

  direction_to_player := normalize(player.transform.position - e.transform.position)
  physics.push(e.body, to_vec2(direction_to_player) * e.speed.current)

  relative_direction_to_player := render.to_camera_relative(direction_to_player.xz)
  e.sprite.flip = relative_direction_to_player.x < 0
}

enemy_attack :: proc(e: ^Entity) {
  player := get_player()
  if player == nil do return

  if e.weapon.fire.current > 0 {
    e.weapon.fire.current -= time.wdt
    return
  }

  distance_to_player := length(player.transform.position - e.transform.position)
  if distance_to_player > 1.25 {
    return
  }

  if !has_status(player, .Invincible) {
    player.health.current -= 1
    set_status(player, .Invincible, 2)
    dir := normalize(e.transform.position - player.transform.position)
    physics.kick(e.body, to_vec2(dir) * 20)
    physics.kick(player.body, to_vec2(-dir) * 100)
  }

  e.weapon.fire.current = e.weapon.fire.interval
}

