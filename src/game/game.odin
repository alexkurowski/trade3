#+private file
package game

import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  box.clear(&entities)

  location_id := spawn(Entity{kind = .Star, name = make_random_name()})
  player.view_location_id = location_id

  for i := 0; i < 3; i += 1 {
    spawn(Entity {
        kind = .Planet,
        location_id = location_id,
        name = make_random_name(),
        position = to_vec3(rand_offset(100, 200), randf(-20, 20)),
      })
  }

  for i := 0; i < 3; i += 1 {
    spawn(Entity {
        kind = .Station,
        location_id = location_id,
        name = make_random_name(),
        position = to_vec3(rand_offset(100, 200), randf(-20, 20)),
      })
  }

  for i := 0; i < 5; i += 1 {
    spawn(Entity {
        kind = .Asteroid,
        location_id = location_id,
        position = to_vec3(rand_offset(100, 200), randf(-20, 20)),
      })
    spawn(Entity {
        kind = .Ship,
        location_id = location_id,
        name = make_random_full_name(),
        position = to_vec3(rand_offset(100, 200), randf(-20, 20)),
      })
  }

  player.ship_id = spawn(Entity {
      kind = .Ship,
      location_id = location_id,
      name = make_random_full_name(),
      position = to_vec3(rand_offset(100, 200), randf(-20, 20)),
    })
}

spawn :: proc(entity: Entity) -> ID {
  id := box.append(&entities, entity)
  box.append(&entity_kind_cache[entity.kind], id)
  return id
}

//
//
//

@(private)
game_loop :: proc() {
  mouse_position := rl.GetMousePosition()

  player.hover_id = none

  player_ship := box.get(&entities, player.ship_id)
  player_plane_y := player_ship.position.y

  is_in_current_location :: #force_inline proc(e: ^Entity) -> bool {
    return e.location_id == player.view_location_id || e.id == player.view_location_id
  }

  is_hover: bool
  for &entity in entities.items {
    if box.skip(entity) do continue

    if entity.kind == .Ship {
      if entity.id != player.ship_id {
        ship_ai(&entity)
      }

      ship_approach(&entity)
      entity.position += entity.velocity * time.wdt
    }

    if is_in_current_location(&entity) {
      screen_position, on_screen := to_screen_position(entity.position)

      is_hover = distance_squared(screen_position, mouse_position) < 100
      if is_hover {
        player.hover_id = entity.id

        if entity.kind == .Asteroid {
          ui.tooltip = "Asteroid"
        } else {
          ui.tooltip = entity.name
        }
      }


      if on_screen {
        draw_sprite(entity.kind, screen_position)
        draw_plane_line(entity.position, player_plane_y)

        if player.selected_id == entity.id {
          rl.DrawCircle3D(entity.position, 0.5, Vec3{1, 0, 0}, 90, rl.GREEN)
        }
      }
    }
  }

  camera_controls()

  {
    left_click := rl.IsMouseButtonPressed(.LEFT)
    right_click := rl.IsMouseButtonPressed(.RIGHT)

    if left_click {
      if player.selected_id != player.hover_id {
        player.selected_id = player.hover_id
      } else {
        player_ship.target_id = player.hover_id
      }
    }
    if right_click && player.hover_id != none {
      pp("Context menu", player.hover_id)
    }
  }

  if player_ship.target_id != none {
    rl.DrawLine3D(
      player_ship.position,
      box.get(&entities, player_ship.target_id).position,
      rl.GRAY,
    )
  }

  {
    // Velocity vector
    rl.DrawLine3D(player_ship.position, player_ship.position + player_ship.velocity, rl.GRAY)
    // Radar circles
    for i := 5; i <= 20; i += 5 {
      rl.DrawCircle3D(player_ship.position, f32(i), Vec3{1, 0, 0}, 90, rl.WHITE)
    }
  }

  if debug_mode {
    rl.DrawGrid(20, 1)
    rl.DrawCircle3D(camera.target, 0.1, {1, 0, 0}, 90, rl.WHITE)
  }
}

ship_ai :: proc(e: ^Entity) {
  if e.target_id == none {
    e.target_id = rand_choice(box.every(&entity_kind_cache[.Asteroid]))
  } else {
    target := box.get(&entities, e.target_id)
    distance_to_target := length(e.position - target.position)
    if distance_to_target <= 0.5 {
      if target.kind == .Asteroid {
        e.target_id = rand_choice(box.every(&entity_kind_cache[.Station]))
      } else {
        e.target_id = rand_choice(box.every(&entity_kind_cache[.Asteroid]))
      }
    }
  }
}

ship_approach :: proc(e: ^Entity) {
  if e.target_id == none do return
  target_position := box.get(&entities, e.target_id).position
  direction := target_position - e.position - e.velocity
  if length(direction) > length(e.velocity) + 0.5 {
    e.velocity += normalize(direction) * time.wdt
  } else {
    e.velocity += (Vec3(0) - e.velocity) * time.wdt
  }
}

camera_controls :: proc() {
  {
    move: Vec3
    speed :: 5
    if rl.IsKeyDown(.A) do move.x = +speed
    if rl.IsKeyDown(.D) do move.x = -speed
    if rl.IsKeyDown(.Q) do move.y = -speed
    if rl.IsKeyDown(.E) do move.y = +speed
    if rl.IsKeyDown(.W) do move.z = +speed
    if rl.IsKeyDown(.S) do move.z = -speed
    if !is_zero(move) {
      move_by := camera.ground_right * move.x + {0, move.y, 0} + camera.ground_forward * move.z
      move_by *= time.dt
      camera.target += move_by
    } else {
      camera.target += (box.get(&entities, player.ship_id).position - camera.target) * 5 * time.dt
    }
  }
  {
    rotate: Vec2
    zoom: f32
    if rl.IsKeyDown(.LEFT_SHIFT) {
      zoom = -rl.GetMouseWheelMoveV().y
    } else {
      rotate = rl.GetMouseWheelMoveV() * 2.5
    }
    camera.angle.x += rotate.x
    camera.angle.y -= rotate.y
    camera.distance += zoom
  }
}
