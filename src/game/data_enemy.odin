#+private
package game

import "physics"
import "render"

spawn_enemy :: proc() {
  DIFFICULTY: struct {
    initial_health: f32,
    health:         f32,
    initial_speed:  f32,
    speed:          f32,
  } : {initial_health = 1, health = 0.01, initial_speed = 10, speed = 0.1}

  door := g.location.doors[randi(0, 1)]
  e := spawn_at(door.position + rand_offset(0, TILE_SIZE / 2))
  e.ai.direction_out_door = to_vec3(door.direction)
  e.kind = {.Enemy, .EnemyMelee}
  e.health = val(DIFFICULTY.initial_health + DIFFICULTY.health * g.round_age)
  e.speed = val(DIFFICULTY.initial_speed + DIFFICULTY.speed * g.round_age)
  e.sprite = {
    kind = .EnemyA,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 2, category = .Enemy)
}

enemy_controls :: proc(e: ^Entity) {
  enemy_move(e)
  enemy_attack(e)
}

enemy_move :: proc(e: ^Entity) {
  direction: Vec3

  if e.age < 1.5 {
    direction = e.ai.direction_out_door
  } else {
    player := get_player()
    if player == nil do return

    direction = normalize(player.transform.position - e.transform.position)
  }

  physics.push(e.body, to_vec2(direction) * e.speed.current)

  relative_direction := render.to_camera_relative(direction.xz)
  e.sprite.flip = relative_direction.x < 0
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

