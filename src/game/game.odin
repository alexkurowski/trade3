#+private file
package game

import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  box.clear(&locations)
  box.clear(&entities)

  sector_idx := box.append(&locations, Location{kind = .Sector, name = make_random_name()})
  player.current_location = sector_idx

  for i := 0; i < 3; i += 1 {
    box.append(
      &locations,
      Location {
        kind = .Planet,
        parent = sector_idx,
        name = make_random_name(),
        position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
      },
    )
  }

  for i := 0; i < 3; i += 1 {
    box.append(
      &locations,
      Location {
        kind = .Station,
        parent = sector_idx,
        name = make_random_name(),
        position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
      },
    )
  }

  for i := 0; i < 5; i += 1 {
    box.append(
      &entities,
      Entity {
        kind = .Asteroid,
        location = sector_idx,
        position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
      },
    )
    box.append(
      &entities,
      Entity {
        kind = .Ship,
        location = sector_idx,
        name = make_random_full_name(),
        position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
      },
    )
  }

  player.current_ship = box.append(
    &entities,
    Entity {
      kind = .Ship,
      location = sector_idx,
      name = make_random_full_name(),
      position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
    },
  )
}

//
//
//

@(private)
game_loop :: proc() {
  mouse_position := rl.GetMousePosition()

  player.hover = ObjectSelector{}

  player_entity := box.get(&entities, player.current_ship)
  player_plane_y := player_entity.position.y

  {
    star := box.get(&locations, player.current_location)
    draw_sprite(.Star, star.position)
  }

  for &location in locations.items {
    if box.skip(location) do continue
    if location.parent != player.current_location do continue

    screen_position, on_screen := to_screen_position(location.position)

    is_hover := distance_squared(screen_position, mouse_position) < 100
    if is_hover {
      player.hover.type = .Location
      player.hover.idx = location.id
      ui.tooltip = location.name
    }

    if on_screen {
      if location.kind == .Planet {
        draw_sprite(.Planet, screen_position)
      } else if location.kind == .Station {
        draw_sprite(.Station, screen_position)
      }
      draw_plane_line(location.position, player_plane_y)

      if player.selected.type == .Location && player.selected.idx == location.id {
        rl.DrawCircle3D(location.position, 0.75, Vec3{1, 0, 0}, 90, rl.GREEN)
      }
    }
  }

  for &entity in entities.items {
    if box.skip(entity) do continue
    if entity.location != player.current_location do continue

    screen_position, on_screen := to_screen_position(entity.position)

    is_hover := distance_squared(screen_position, mouse_position) < 100
    if is_hover {
      player.hover.type = .Entity
      player.hover.idx = entity.id

      if entity.kind == .Asteroid {
        ui.tooltip = "Asteroid"
      } else {
        ui.tooltip = entity.name
      }
    }

    if entity.kind == .Ship {
      ship_ai(&entity)
    }

    entity.position += entity.velocity * time.wdt

    if on_screen {
      if entity.kind == .Ship {
        draw_sprite(.Ship, screen_position)
      } else if entity.kind == .Asteroid {
        draw_sprite(.Asteroid, screen_position)
      }
      draw_plane_line(entity.position, player_plane_y)

      if player.selected.type == .Entity && player.selected.idx == entity.id {
        rl.DrawCircle3D(entity.position, 0.5, Vec3{1, 0, 0}, 90, rl.GREEN)
      }
    }
  }

  camera_controls()

  {
    left_click := rl.IsMouseButtonPressed(.LEFT)
    right_click := rl.IsMouseButtonPressed(.RIGHT)

    if left_click {
      player.selected = player.hover
    }
    if right_click && player.hover.type != .None {
      player_entity.target = player.hover
    }
  }

  if player_entity.target.type != .None {
    switch player_entity.target.type {
    case .None: // NOP
    case .Location:
      rl.DrawLine3D(
        player_entity.position,
        box.get(&locations, player_entity.target.idx).position,
        rl.GRAY,
      )
    case .Entity:
      rl.DrawLine3D(
        player_entity.position,
        box.get(&entities, player_entity.target.idx).position,
        rl.GRAY,
      )
    }
  }

  {
    // Velocity vector
    rl.DrawLine3D(player_entity.position, player_entity.position + player_entity.velocity, rl.GRAY)
    // Radar circles
    for i := 5; i <= 20; i += 5 {
      rl.DrawCircle3D(player_entity.position, f32(i), Vec3{1, 0, 0}, 90, rl.WHITE)
    }
  }

  if debug_mode {
    rl.DrawGrid(20, 1)
    rl.DrawCircle3D(camera.target, 0.1, {1, 0, 0}, 90, rl.WHITE)
  }
}

ship_ai :: proc(e: ^Entity) {
  target_position: Vec3
  switch e.target.type {
  case .None:
    return
  case .Location:
    target_position = box.get(&locations, e.target.idx).position
  case .Entity:
    target_position = box.get(&entities, e.target.idx).position
  }

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
      camera.target +=
        (box.get(&entities, player.current_ship).position - camera.target) * 5 * time.dt
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
