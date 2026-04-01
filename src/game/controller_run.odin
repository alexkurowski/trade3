#+private
package game

import cont "containers"
import "core:fmt"
import "physics"
import "render"
import "text"
import "ui"
import rl "vendor:raylib"

state_run_ready :: proc() {
  {
    // Unload everything
    clear_all_subscribed_events()
    despawn_all_bullets()
    despawn_all_collectables()
    despawn_all_entities()
    reset_player()
  }

  {
    // Generate fresh state
    reset_round()
    generate_location()
    spawn_player()
    reset_weapon()
    apply_upgrades()

    // DEBUG: spawn some obstacles
    for i := 0; i < 4; i += 1 {
      angle := f32(i) * PI / 2
      spawn_small_wall(to_vec3(at_angle(angle) * 4), angle + PI / 2)
    }
  }

  rl.HideCursor()
}

state_run :: proc() {
  time_step()

  update_round()

  draw_location()
  update_bullets()
  update_entities()
  update_collectables()

  physics.update(time.wdt)

  if rl.IsKeyPressed(.R) {
    set_state(.Run)
  }

  update_input()
  update_spawners()

  draw_player_hud()
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
  enemy_count := u32(0)
  closest_enemy: struct {
    id:       ID,
    distance: f32,
  } = {
    distance = 999999,
  }

  #reverse for &e in g.entities.items {
    if is_none(e.id) do continue

    if e.health.current <= 0 {
      die(&e)
      despawn(e.id)
      continue
    }

    e.age += time.wdt

    update_entity_statuses(&e)
    update_entity_transform(&e)

    if .Player in e.kind {
      player_controls(&e)
      player_camera_follow(&e)
    }
    if .Enemy in e.kind {
      enemy_count += 1
      enemy_controls(&e)
      enemy_auto_aim(&e, &closest_enemy)
    }

    draw_entity(&e)
    draw_health(&e)
  }

  g.round.enemy_count = enemy_count

  if !is_none(closest_enemy.id) {
    target_entity := cont.get(&g.entities, closest_enemy.id)
    if target_entity != nil {
      g.player.aim.position +=
        (target_entity.transform.position - g.player.aim.position) * 5 * time.wdt
    }
  }
}

update_entity_statuses :: proc(e: ^Entity) {
  e.status[.Invincible].current -= time.wdt
}

update_entity_transform :: proc(e: ^Entity) {
  t := physics.get_transform(e.body)
  e.transform.position = to_vec3(t.position, e.transform.position.y)
  e.transform.velocity = to_vec3(t.velocity, e.transform.velocity.y)
  e.transform.rotation = t.rotation
}

draw_entity :: proc(e: ^Entity) {
  if e.sprite.kind != .None {
    if has_status(e, .Invincible) {
      if int(e.status[.Invincible].current * 7) % 2 == 0 {
        // Draw blinking effect when invincible
        return
      }
    }
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
    prev_position := b.position
    b.position += b.velocity * time.wdt
    next_position := b.position

    if length(b.position) > BULLET_AREA_LIMIT {
      despawn_bullet(i32(idx))
      continue
    }
    if bullet_check_collision_raycast(&b, prev_position, next_position) {
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
  ACCELERATION :: 7.5
  FRICTION :: 2.25

  player := get_player()
  if player == nil do return

  #reverse for &c, idx in cont.every(&g.collectables) {
    c.position += c.velocity * time.wdt
    c.velocity -= c.velocity * time.wdt * FRICTION

    distance_to_player := length(c.position - player.transform.position)
    if distance_to_player < g.player.pickup_radius {
      pickup_collectable(&c)
      despawn_collectable(i32(idx))
      continue
    } else if distance_to_player < g.player.pickup_radius * 2 {
      direction_to_player := normalize(player.transform.position - c.position)
      c.velocity += direction_to_player * time.wdt * ACCELERATION
      c.velocity.y = 0
    }
    draw_collectable(&c)
  }
}

draw_collectable :: proc(c: ^Collectable) {
  if c.amount < 10 {
    render.sprite(.CollectableA, c.position)
  } else {
    render.sprite(.CrateA, c.position, flip = c.flip)
  }
}

//
//
//

update_input :: proc() {
  // Lock mouse cursor to center
  rl.SetMousePosition(rl.GetScreenWidth() / 2, rl.GetScreenHeight() / 2)
}

//
//
//

update_round :: proc() {
  g.round.age += time.wdt
  g.round.tick_timeout -= time.wdt
  g.round.spawn_timeout -= time.wdt
  g.round.crate_timeout -= time.wdt

  if g.round.tick_timeout <= 0 {
    g.round.tick_timeout = g.round.tick_interval
    g.round.max_enemy_count += 2
    g.round.spawn_timeout = g.round.spawn_interval * 5
  }
}

update_spawners :: proc() {
  if g.debug do return

  if g.round.spawn_timeout <= 0 {
    if g.round.enemy_count < g.round.max_enemy_count {
      g.round.spawn_timeout = g.round.spawn_interval
      spawn_enemy()
    }
  }

  if g.round.crate_timeout <= 0 {
    g.round.crate_timeout = g.round.crate_interval
    spawn_collectable_crate()
  }
}

//
//
//

draw_player_hud :: proc() {
  player := get_player()
  if player == nil do return

  {
    // Draw aim spray circle
    offset := Vec3{0, PLAYER_AIM_HEIGHT, 0}
    position := render.get_screen_position(g.player.aim.position + offset)
    render.hud(.AimCircle, position, g.player.aim.screen_radius)
  }

  if g.player.aim.show_last_timeout < 0 {
    render.hud(
      .ShotCircle,
      render.get_screen_position(g.player.aim.position + Vec3{0, PLAYER_AIM_HEIGHT, 0}),
      2,
    )
  } else {
    g.player.aim.show_last_timeout -= time.dt
    render.hud(
      .ShotCircle,
      render.get_screen_position(g.player.aim.last_shot + Vec3{0, PLAYER_AIM_HEIGHT, 0}),
      2,
    )
  }

  render.hud(
    .ReloadCounter,
    render.get_screen_position(player.transform.position + Vec3{0, 2, 0}),
    g.player.weapon.reload.current / g.player.weapon.reload.duration,
    g.player.weapon.reload.qte_start,
    g.player.weapon.reload.qte_duration,
  )

  if UI()({}) {
    if UI()({layout = {padding = {8, 8, 42, 8}}}) {
      ui.text(
        fmt.tprintf(
          "Ammo: %v/%v (%v)",
          g.player.weapon.clip.current,
          g.player.weapon.clip.max,
          g.player.weapon.ammo.current,
        ),
      )
    }
  }
  if UI()({}) {
    if UI()({layout = {padding = {8, 8, 42, 8}}}) {
      ui.text(text.format_number(1))
    }
  }
}

draw_health :: proc(e: ^Entity) {
  if .Player in e.kind {
    render.hud(
      .HealthBar,
      render.get_screen_position(e.transform.position + Vec3{0, -0.5, 0}),
      e.health.current / e.health.max,
    )
  } else if .Enemy in e.kind {
    if e.health.current < e.health.max {
      render.hud(
        .HealthBarSmall,
        render.get_screen_position(e.transform.position + Vec3{0, -0.5, 0}),
        e.health.current / e.health.max,
      )
    }
  }
}

