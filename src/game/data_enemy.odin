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
  e.health = val(DIFFICULTY.initial_health + DIFFICULTY.health * g.round.age)
  e.speed = val(DIFFICULTY.initial_speed + DIFFICULTY.speed * g.round.age)
  e.sprite = {
    kind = .EnemyA,
    size = 1,
  }
  e.radius = 0.75
  physics.set_body_shape(&e.body, .Circle, e.radius, mass = 2, category = .Enemy)

  if .EnemyMelee in e.kind {
    e.weapon.range = e.radius + PLAYER_RADIUS
  } else if .EnemyRanged in e.kind {
    e.weapon.range = 8
  }
}

enemy_controls :: proc(e: ^Entity) {
  enemy_move(e)
  enemy_attack(e)
}

enemy_move :: proc(e: ^Entity) {
  player := get_player()
  if player == nil do return

  direction: Vec3
  if e.age < 1.5 {
    direction = e.ai.direction_out_door
  } else if .EnemyMelee in e.kind {
    direction = normalize(player.transform.position - e.transform.position)
  } else if .EnemyRanged in e.kind {
    direction = normalize(player.transform.position - e.transform.position)
    if length(player.transform.position - e.transform.position) < e.weapon.range * 0.75 {
      return
    }
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

  direction_to_player := player.transform.position - e.transform.position
  distance_to_player := length(direction_to_player)

  should_attack := false
  if .EnemyMelee in e.kind {
    if distance_to_player < e.radius + player.radius {
      should_attack = true
    }
  } else if .EnemyRanged in e.kind {
    if distance_to_player < e.weapon.range {
      should_attack = true
    }
  }
  if !should_attack do return

  e.weapon.fire.current = e.weapon.fire.interval

  // TODO: move this into separate function
  //       because same things needed for damage by bullets
  if !has_status(player, .Invincible) {
    player.health.current -= 1
    set_status(player, .Invincible, 2)
    dir := normalize(e.transform.position - player.transform.position)
    physics.kick(e.body, to_vec2(dir) * 20)
    physics.kick(player.body, to_vec2(-dir) * 100)
  }
}

