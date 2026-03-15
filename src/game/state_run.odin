#+private
package game

import cont "containers"
import "core:fmt"
import "physics"
import "render"
import rl "vendor:raylib"

state_run_ready :: proc() {
  despawn_all_bullets()
  despawn_all_entities()
  spawn_player()
  spawn_circle_at({1, 0, 0}, 0.6, 2)
  spawn_circle_at({0, 0, 2}, 0.3, 3)
  spawn_circle_at({-2, 0, 1}, 0.3, 4)
  spawn_box_at({-1, 0, -4}, 45 * DEG_TO_RAD, 5, 2, 0.5)
}

state_run :: proc() {
  process_systems()
  process_events()
  process_spawners()
}

@(private)
process_systems :: proc() {
  time_step()

  draw_map()
  update_entities()

  physics.update(time.dt)

  update_bullets()

  if rl.IsKeyPressed(.R) {
    set_state(.Run)
  }
}

draw_map :: proc() {
  render.shape(.Plane, Vec3(0), Vec2(50), Color{20, 20, 30, 255})
}

update_entities :: proc() {
  g.player = cont.get(&g.entities, g.player_id)

  #reverse for &e in g.entities.items {
    if cont.is_none(e) do continue

    if .Player in e.kind {
      player_controls(&e)
      player_camera_follow(&e)
    }
    if .Enemy in e.kind {
      ai_controls(&e)
    }

    update_transform(&e)
    draw(&e)
  }
}

update_transform :: proc(e: ^Entity) {
  t := physics.get_transform(e.body)
  e.transform.position = to_vec3(t.position, e.transform.position.y)
  e.transform.velocity = to_vec3(t.velocity, e.transform.velocity.y)
  e.transform.rotation = t.rotation
}

draw :: proc(e: ^Entity) {
  if e.sprite.kind != .None {
    render.sprite(e.sprite.kind, e.transform.position, e.sprite.size, e.sprite.flip)
  }
}

process_spawners :: proc() {
  ENEMY_SPAWN_INTERVAL :: 0.1

  @(static) enemy_spawn_timer: f32
  enemy_spawn_timer -= time.wdt

  if enemy_spawn_timer <= 0 {
    spawn_enemy()
    enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
  }
}

update_bullets :: proc() {
  #reverse for &b, idx in cont.every(&g.bullets) {
    b.position += b.velocity * time.wdt
    if length(b.position) > 25 {
      despawn_bullet(i32(idx))
      continue
    }
    collision := physics.query_collision(b.position, 0.5, .Enemy | .Obstacle)
    if collision.hit {
      despawn_bullet(i32(idx))
      continue
    }
    render.shape(.Sphere, b.position, 0.1, rl.WHITE)
  }
}

// on_bullet_entity_collision :: proc(bid: physics.BID) {
//   id := g.body_to_entity[bid]
//   e := cont.get(&g.entities, id)
//   if cont.is_none(e) do return
//   fmt.println("HIT")
// }

