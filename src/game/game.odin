#+private file
package game

import "core:slice"
import "core:strings"
import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  world_clear()
  generate_new_world()
}

@(private)
game_update :: proc() {
  reset_input()
  camera_controls()

  // TODO: scene switch
  update_companies()
  update_and_draw_locations()
  update_and_draw_entities()

  draw_ui_location_breadcrumb()

  camera_controls()

  if g.debug_mode {
    rl.DrawGrid(20, 1)
    rl.DrawCircle3D(camera.target, 0.1, {1, 0, 0}, 90, rl.WHITE)

    if rl.IsKeyPressed(.R) {
      start_new_game()
    }
  }

  if rl.IsKeyPressed(.SLASH) do g.debug_mode = !g.debug_mode
}

reset_input :: proc() {
  g.mouse_position = rl.GetMousePosition()
  g.location_hover_id = none
  g.entity_hover_id = none
}

camera_controls :: proc() {
  if g.debug_mode {
    move: Vec3
    speed :: 5
    if rl.IsKeyDown(.A) do move.x = +speed
    if rl.IsKeyDown(.D) do move.x = -speed
    if rl.IsKeyDown(.Q) do move.y = -speed
    if rl.IsKeyDown(.E) do move.y = +speed
    if rl.IsKeyDown(.W) do move.z = +speed
    if rl.IsKeyDown(.S) do move.z = -speed
    move_by := camera.ground_right * move.x + {0, move.y, 0} + camera.ground_forward * move.z
    move_by *= time.dt
    camera.target += move_by
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

update_and_draw_locations :: proc() {
  current_location := box.get(&w.locations, g.location_view_id)

  for &location in w.locations.items {
    if box.skip(location) do continue
    if g.location_view_id != location.parent_id do continue

    rl.DrawSphere(location.position, 0.5, rl.WHITE)

    // Hover
    screen_position, on_screen := to_screen_position(location.position)
    if on_screen && distance(g.mouse_position, screen_position) < 5 {
      g.location_hover_id = location.id
      ui.tooltip = location.name
      rl.DrawSphereWires(location.position, 0.75, 6, 6, rl.GRAY)
    }

    // Draw connection routes
    if location.kind == .System {
      for conn_id in box.every(&location.connection_ids) {
        if location.id.idx > conn_id.idx do continue

        other_location := box.get(&w.locations, conn_id)
        rl.DrawLine3D(location.position, other_location.position, rl.WHITE)
      }
    }

    // Draw planet orbit
    if location.kind == .Planet {
      distance := length(location.position - current_location.position)
      rl.DrawCircle3D(current_location.position, distance, Vec3{1, 0, 0}, 90, rl.WHITE)
    }
  }

  // Draw current location parent (star or planet)
  if current_location != nil {
    if current_location.kind == .System {
      rl.DrawSphere(current_location.position, 2, rl.YELLOW)
    } else if current_location.kind == .Planet {
      rl.DrawSphereWires(current_location.position, current_location.size, 6, 12, rl.GREEN)
    }
  }

  // Location selection
  if rl.IsMouseButtonPressed(.LEFT) && g.location_hover_id != none {
    if current_location == nil || current_location.kind != .Planet {
      location := box.get(&w.locations, g.location_hover_id)
      if location != nil {
        g.location_view_id = location.id
        camera.target = location.position
      }
    }
  } else if rl.IsMouseButtonPressed(.RIGHT) {
    if current_location != nil && current_location.kind != .None {
      location := box.get(&w.locations, current_location.parent_id)
      if location != nil {
        g.location_view_id = location.id
        camera.target = location.position
      } else {
        g.location_view_id = none
        camera.target = current_location.position
      }
    }
  }
}

draw_ui_location_breadcrumb :: proc() {
  location := box.get(&w.locations, g.location_view_id)
  if location == nil do return

  path: box.Pool(string, 4)

  for location != nil {
    box.append(&path, location.name)
    location = box.get(&w.locations, location.parent_id)
  }

  slice.reverse(box.every(&path))

  if !box.is_empty(&path) {
    if UI()({}) {
      ui_text(strings.join(box.every(&path), " > ", context.temp_allocator))
    }
  }
}

update_companies :: proc() {
  for &company in w.companies.items {
    if box.skip(company) do continue
  }
}

update_and_draw_entities :: proc() {
  for &entity in w.entities.items {
    if box.skip(entity) do continue
  }
}
