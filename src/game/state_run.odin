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
  update_entities()

  physics.update(time.dt)

  update_bullets()
  update_collectables()

  if rl.IsKeyPressed(.R) {
    set_state(.Run)
  }

  process_events()

  update_spawners()

  render.icon(.Circle, render.get_mouse_screen_position(), 10)
}

//
//
//

draw_map :: proc() {
  render.shape(.Plane, Vec3(0), Vec2(50), Color{20, 20, 30, 255})
}

//
//
//

update_entities :: proc() {
  g.player = cont.get(&g.entities, g.player_id)

  #reverse for &e in g.entities.items {
    if is_none(e.id) do continue

    if .Player in e.kind {
      player_controls(&e)
      player_camera_follow(&e)
    }
    if .Enemy in e.kind {
      ai_controls(&e)
    }

    update_entity_transform(&e)
    draw_entity(&e)
  }
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
  get_collision_mask :: proc(b: ^Bullet) -> physics.CollisionLayer {
    if b.from == .Player {
      if b.low {
        return .Enemy | .Obstacle | .SemiObstacle
      } else {
        return .Enemy | .Obstacle
      }
    } else {
      if b.low {
        return .Player | .Obstacle | .SemiObstacle
      } else {
        return .Player | .Obstacle
      }
    }
  }

  #reverse for &b, idx in cont.every(&g.bullets) {
    b.position += b.velocity * time.wdt
    if length(b.position) > 25 {
      despawn_bullet(i32(idx))
      continue
    }
    collision := physics.query_collision(b.position, 0.5, get_collision_mask(&b))
    if collision.hit {
      id := g.body_to_entity[collision.bid]
      e := cont.get(&g.entities, id)
      if e != nil {
        hurt(e, 1)
      }
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
  #reverse for &c, idx in cont.every(&g.collectables) {
    distance_to_player := length(c.position - g.player.transform.position)
    if distance_to_player < 1 {
      // Pickup
      despawn_collectable(i32(idx))
      continue
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
  ENEMY_SPAWN_INTERVAL :: 0.1

  @(static) enemy_spawn_timer: f32
  enemy_spawn_timer -= time.wdt

  if enemy_spawn_timer <= 0 {
    spawn_enemy()
    enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
  }
}

