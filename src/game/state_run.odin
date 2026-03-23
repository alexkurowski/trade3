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
    clear_all_events()
    despawn_all_bullets()
    despawn_all_collectables()
    despawn_all_entities()

    reset_player()
  }

  {
    // Generate fresh state
    generate_location()

    spawn_player()
    spawn_player_base()

    for i := 0; i < 4; i += 1 {
      angle := f32(i) * PI / 2
      spawn_small_wall(to_vec3(at_angle(angle) * 4), angle + PI / 2)
    }
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

  draw_player_hud()
}

//
//
//

update_input :: proc() {
  g.player.mouse = render.get_screen_position(g.player.aim)
  g.player.mouse += rl.GetMouseDelta()
  g.player.aim = render.get_world_position(g.player.mouse)
  // TODO: Fix reticle going off-screen

  // Lock actual mouse cursor to center
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
  enemy_count := u32(0)

  #reverse for &e in g.entities.items {
    if is_none(e.id) do continue

    if e.health.current <= 0 {
      die(&e)
      despawn(e.id)
      continue
    }

    update_entity_statuses(&e)

    if .Player in e.kind {
      player_controls(&e)
      player_camera_follow(&e)
    }
    if .Enemy in e.kind {
      enemy_count += 1
      enemy_controls(&e)
    }
    if .Base in e.kind {
      base_update(&e)
    }

    update_entity_transform(&e)
    draw_entity(&e)
  }

  g.enemy_count = enemy_count
}

base_update :: proc(e: ^Entity) {
  player := get_player()
  if player == nil do return

  TRANSFER_INTERVAL :: 0.33
  @(static) transfer_timer: f32
  transfer_timer -= time.wdt

  TRANSFER_INFO_DURATION :: 2
  @(static) transfer_info_timer: f32
  transfer_info_timer -= time.wdt
  @(static) transfer_info_amount: u64
  if transfer_info_timer <= 0 do transfer_info_amount = 0

  TRANSFER_RADIUS :: 3
  distance_to_player := length(e.transform.position - player.transform.position)
  should_transfer := distance_to_player < TRANSFER_RADIUS

  MAX_TRANSFER_AMOUNT :: 1

  if should_transfer && transfer_timer <= 0 {
    transfer_timer = TRANSFER_INTERVAL

    amount_transferred := u64(0)
    for kind in ResourceKind {
      if g.player.inventory.resources[kind] > 0 {
        amount := min(g.player.inventory.resources[kind], MAX_TRANSFER_AMOUNT)
        g.player.inventory.resources[kind] -= amount
        g.progress.inventory.resources[kind] += amount
        amount_transferred += amount
      }
    }

    if amount_transferred > 0 {
      transfer_info_amount += amount_transferred
      transfer_info_timer = TRANSFER_INFO_DURATION
    }
  }

  if transfer_info_amount > 0 {
    if UI()({floating = {offset = render.get_screen_position(Vec3{0, 2, 0}), attachTo = .Root}}) {
      ui.text(text.format_number_prefix('+', f32(transfer_info_amount)))
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
  FRICTION :: 2.25

  player := get_player()
  if player == nil do return

  #reverse for &c, idx in cont.every(&g.collectables) {
    c.position += c.velocity * time.wdt
    c.velocity -= c.velocity * time.wdt * FRICTION

    distance_to_player := length(c.position - player.transform.position)
    if distance_to_player < g.progress.pickup_radius {
      pickup_collectable(&c)
      despawn_collectable(i32(idx))
      continue
    } else if distance_to_player < g.progress.pickup_radius * 2 {
      c.velocity += distance_to_player * time.wdt
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

draw_player_hud :: proc() {
  player := get_player()
  if player == nil do return

  render.hud(.Circle, render.get_screen_position(g.player.aim + Vec3{0, PLAYER_AIM_HEIGHT, 0}), 10)
  render.hud(
    .ReloadCounter,
    render.get_screen_position(player.transform.position + Vec3{0, 2, 0}),
    g.player.weapon.reload.current / g.player.weapon.reload.duration,
    g.player.weapon.reload.qte_start,
    g.player.weapon.reload.qte_duration,
  )
  render.hud(
    .HealthBar,
    render.get_screen_position(player.transform.position + Vec3{0, -0.5, 0}),
    player.health.current / player.health.max,
  )

  if UI()({}) {
    if UI()({layout = {padding = {8, 8, 42, 8}}}) {
      ui.text(fmt.tprintf("Ammo: %v/%v", g.player.weapon.ammo.current, g.player.weapon.ammo.max))
    }
  }
  if UI()({}) {
    if UI()({layout = {padding = {8, 8, 42, 8}}}) {
      ui.text(text.format_number(1))
    }
  }
}

