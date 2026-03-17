#+private
package game

import cont "containers"
import "physics"
import "render"
import rl "vendor:raylib"

state_run_ready :: proc() {
  clear_all_events()
  despawn_all_bullets()
  despawn_all_collectables()
  despawn_all_entities()
  spawn_player()
  for i := 0; i < 4; i += 1 {
    angle := f32(i) * PI / 2
    spawn_small_wall(to_vec3(at_angle(angle) * 4), angle + PI / 2)
  }

  rl.HideCursor()
}

state_run :: proc() {
  time_step()

  draw_map()
  update_bullets()
  update_entities()

  physics.update(time.dt)

  update_collectables()

  if rl.IsKeyPressed(.R) {
    set_state(.Run)
  }

  // process_events()

  update_spawners()

  render.icon(.Circle, render.get_mouse_screen_position(), 10)
}

//
//
//

draw_map :: proc() {
  render.shape(.Plane, Vec3(0), Vec2(100), Color{20, 20, 30, 255})
}

//
//
//

update_entities :: proc() {
  g.player = cont.get(&g.entities, g.player_id)
  enemy_count := u32(0)

  #reverse for &e in g.entities.items {
    if is_none(e.id) do continue

    if e.health.current <= 0 {
      spawn_collectable_at(.None, e.transform.position)
      despawn(e.id)
      continue
    }

    if .Player in e.kind {
      player_controls(&e)
      player_camera_follow(&e)
    }
    if .Enemy in e.kind {
      enemy_count += 1
      ai_controls(&e)
    }

    update_entity_transform(&e)
    draw_entity(&e)
  }

  g.enemy_count = enemy_count
}

update_entity_transform :: proc(e: ^Entity) {
  t := physics.get_transform(e.body)
  e.transform.position = to_vec3(t.position, e.transform.position.y)
  e.transform.velocity = to_vec3(t.velocity, e.transform.velocity.y)
  e.transform.rotation = t.rotation
}

draw_entity :: proc(e: ^Entity) {
  if e.sprite.kind != .None {
    render.sprite(e.sprite.kind, e.transform.position, e.sprite.size, e.sprite.flip)
  }
  if e.model.kind != .None {
    render.model(e.model.kind, e.transform.position, e.transform.rotation)
  }
}

//
//
//

update_bullets :: proc() {
  #reverse for &b, idx in cont.every(&g.bullets) {
    b.position += b.velocity * time.wdt
    if length(b.position) > BULLET_AREA_LIMIT {
      despawn_bullet(i32(idx))
      continue
    }
    if bullet_check_collision_radius(&b) {
      despawn_bullet(i32(idx))
      continue
    }
    draw_bullet(&b)
  }
}

draw_bullet :: proc(b: ^Bullet) {
  render.shape(.Sphere, b.position, 0.1, rl.WHITE)
}

//
//
//

update_collectables :: proc() {
  SPEED :: 10

  #reverse for &c, idx in cont.every(&g.collectables) {
    c.position += c.velocity * time.wdt
    distance_to_base := length(c.position)
    distance_to_player := length(c.position - g.player.transform.position)
    if distance_to_player < 1 {
      // Pickup
      despawn_collectable(i32(idx))
      continue
    }
    if distance_to_base > PLAYER_AREA_LIMIT {
      c.velocity = -normalize(c.position) * SPEED
    } else {
      c.velocity -= c.velocity * randf(0.5, 2) * time.wdt
    }
    draw_collectable(&c)
  }
}

draw_collectable :: proc(c: ^Collectable) {
  render.shape(.Sphere, c.position, 0.1, rl.YELLOW)
}

//
//
//

update_spawners :: proc() {
  MAX_ENEMY_COUNT :: 50 // NOTE: this will depend on difficulty
  if g.enemy_count > MAX_ENEMY_COUNT {
    return
  }

  ENEMY_SPAWN_INTERVAL :: 0.1

  @(static) enemy_spawn_timer: f32
  enemy_spawn_timer -= time.wdt

  if enemy_spawn_timer <= 0 {
    spawn_enemy()
    enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
  }
}

