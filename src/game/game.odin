#+private file
package game

import "core:strings"
import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  reset_world()
  generate_new_world()
}

//
//
//

@(private)
scene_update_and_render :: proc() {
  reset_input()
  camera_controls()

  // TODO: scene switch
  draw_locations()
  draw_location_breadcrumb_ui()

  if g.debug_mode {
    camera_controls()
    rl.DrawGrid(20, 1)
    rl.DrawCircle3D(camera.target, 0.1, {1, 0, 0}, 90, rl.WHITE)
  }
}

reset_input :: proc() {
  g.mouse_position = rl.GetMousePosition()
  g.location_hover_id = none
  g.entity_hover_id = none
}

draw_locations :: proc() {
  current_location := box.get(&world.locations, g.location_view_id)

  for &location in world.locations.items {
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

        other_location := box.get(&world.locations, conn_id)
        rl.DrawLine3D(location.position, other_location.position, rl.WHITE)
      }
    }

    // Draw planet orbit
    if location.kind == .Planet {
      distance := length(location.position)
      rl.DrawCircle3D(Vec3(0), distance, Vec3{1, 0, 0}, 90, rl.WHITE)
    }
  }

  // Draw system star
  if current_location != nil {
    if current_location.kind == .System {
      rl.DrawSphere(Vec3(0), 2, rl.YELLOW)
    } else if current_location.kind == .Planet {
      rl.DrawSphereWires(Vec3(0), current_location.size, 6, 12, rl.GREEN)
    }
  }

  if rl.IsMouseButtonPressed(.LEFT) && g.location_hover_id != none {
    if current_location == nil || current_location.kind != .Planet {
      g.location_view_id = g.location_hover_id
    }
  } else if rl.IsMouseButtonPressed(.RIGHT) {
    if current_location != nil && current_location.kind != .None {
      g.location_view_id = current_location.parent_id
    }
  }
}

draw_location_breadcrumb_ui :: proc() {
  location := box.get(&world.locations, g.location_view_id)
  if location == nil do return

  path: [4]string
  i: i32

  for location != nil {
    path[i] = location.name
    i += 1
    location = box.get(&world.locations, location.parent_id)
  }

  if UI()({}) {
    text(strings.join(path[:], " > ", context.temp_allocator))
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
