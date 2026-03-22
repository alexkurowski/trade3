#+private
package game

import cont "containers"
import "core:fmt"
import "physics"
import "render"
import "ui"
import rl "vendor:raylib"

state_run_ready :: proc() {
  clear_all_events()
  despawn_all_bullets()
  despawn_all_collectables()
  despawn_all_entities()

  generate_location()

  spawn_player()
  for i := 0; i < 4; i += 1 {
    angle := f32(i) * PI / 2
    spawn_small_wall(to_vec3(at_angle(angle) * 4), angle + PI / 2)
  }

  rl.HideCursor()
}

state_run :: proc() {
  time_step()
  update_input()

  draw_location()
  update_bullets()
  update_entities()

  physics.update(time.dt)

  update_collectables()

  if rl.IsKeyPressed(.R) {
    set_state(.Run)
  }

  // process_events()

  update_spawners()

  render.ui(.Circle, render.get_screen_position(g.player_aim), 10)
  render.ui(
    .ReloadCounter,
    render.get_screen_position(g.player.transform.position + Vec3{0, 2, 0}),
    g.player.weapon.reload.current / g.player.weapon.reload.duration,
    Vec2{g.player.weapon.reload.qte_start, g.player.weapon.reload.qte_duration},
  )

  draw_ui()
}

//
//
//

update_input :: proc() {
  reticle_screen_position := render.get_screen_position(g.player_aim)
  reticle_screen_position += rl.GetMouseDelta()
  g.player_aim = render.get_world_position(reticle_screen_position)
  // TODO: Fix reticle going off-screen

  // Lock mouse to center
  rl.SetMousePosition(rl.GetScreenWidth() / 2, rl.GetScreenHeight() / 2)
}

//
//
//

draw_location :: proc() {
  for i := 0; i < MAP_SIZE; i += 1 {
    for j := 0; j < MAP_SIZE; j += 1 {
      tile := g.location.tiles[i][j]
      if tile.kind == .None do continue

      x, y := f32(i + TILE_OFFSET) * TILE_SIZE, f32(j + TILE_OFFSET) * TILE_SIZE
      draw_tile(tile, Vec2{x, y})
    }
  }
}

draw_tile :: proc(tile: Tile, position: Vec2) {
  if tile.kind == .Floor {
    render.shape(
      .Cube,
      to_vec3(position, -0.25),
      Vec3{TILE_SIZE, 0.5, TILE_SIZE},
      Color{50, 50, 60, 255},
    )
  } else if tile.kind == .Wall {
    render.shape(
      .Cube,
      to_vec3(position, 1.25),
      Vec3{TILE_SIZE, 3.5, TILE_SIZE},
      Color{30, 30, 42, 255},
    )
  } else if tile.kind == .DoorWall {
    render.shape(
      .Cube,
      to_vec3(position, 2.5),
      Vec3{TILE_SIZE, 1, TILE_SIZE},
      Color{30, 30, 42, 255},
    )
    render.shape(
      .Cube,
      to_vec3(position, -0.25),
      Vec3{TILE_SIZE, 0.5, TILE_SIZE},
      Color{50, 50, 60, 255},
    )
  } else if tile.kind == .DoorFloor {
    render.shape(
      .Cube,
      to_vec3(position, -0.25),
      Vec3{TILE_SIZE, 0.5, TILE_SIZE},
      Color{50, 50, 60, 255},
    )
  }
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
      enemy_controls(&e)
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
  MAX_ENEMY_COUNT :: 20 // NOTE: this will depend on difficulty
  if g.enemy_count > MAX_ENEMY_COUNT {
    return
  }

  ENEMY_SPAWN_INTERVAL :: 0.75

  @(static) enemy_spawn_timer: f32
  enemy_spawn_timer -= time.wdt

  if enemy_spawn_timer <= 0 {
    spawn_enemy()
    enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
  }
}

//
//
//

draw_ui :: proc() {
  player := g.player
  if player == nil do return

  if UI()({}) {
    if UI()({layout = {padding = {8, 8, 42, 8}}}) {
      ui.text(fmt.tprintf("Ammo: %v/%v", player.weapon.ammo.current, player.weapon.ammo.max))
    }
  }
}

