#+private file
package game

import "deps:box"
import rl "vendor:raylib"

player: struct {
  current_location: EID,
}

//
//
//

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
        kind = .Spacecraft,
        location = sector_idx,
        name = make_random_full_name(),
        position = to_vec3(rand_offset(5, 10), randf(-5, 5)),
      },
    )
  }
}

//
//
//

@(private)
game_loop :: proc() {
  mouse_position := rl.GetMousePosition()

  HoverType :: enum {
    None,
    Location,
    Entity,
  }
  hover_type := HoverType.None
  hover_idx := none

  for &location in locations.items {
    if box.skip(location) do continue
    if location.parent != player.current_location do continue

    screen_position, on_screen := to_screen_position(location.position)

    is_hover := distance_squared(screen_position, mouse_position) < 100
    if is_hover {
      hover_type = .Location
      hover_idx = location.id
      ui.tooltip = location.name
    }

    if on_screen {
      if location.kind == .Planet {
        draw_sprite(.Circle, screen_position)
      } else if location.kind == .Station {
        draw_sprite(.Square, screen_position)
      }
      draw_plane_line(location.position)
    }
  }

  for &entity in entities.items {
    if box.skip(entity) do continue
    if entity.location != player.current_location do continue

    screen_position, on_screen := to_screen_position(entity.position)

    is_hover := distance_squared(screen_position, mouse_position) < 100
    if is_hover {
      hover_type = .Entity
      hover_idx = entity.id
      ui.tooltip = entity.name
    }

    if on_screen {
      draw_sprite(.TriangleUp, screen_position)
      draw_plane_line(entity.position)
    }
  }

  camera_controls()

  switch hover_type {
  case .None: // NOP
  case .Location:
  case .Entity:
  }

  if debug_mode {
    rl.DrawGrid(20, 1)
    rl.DrawCircle3D(camera.target, 0.1, {1, 0, 0}, 90, rl.WHITE)
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
