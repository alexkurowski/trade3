#+private file
package game

import "core:slice"
import "core:strings"
import "deps:box"
import rl "vendor:raylib"

@(private)
start_new_game :: proc() {
  world_cleanup()
  generate_new_world()
}

@(private)
game_update :: proc() {
  reset_input()
  camera_step()

  // TODO: scene switch
  update_and_draw_locations()
  update_and_draw_entities()
  update_companies()
  process_input()
  camera_controls()

  draw_ui_location_breadcrumb()

  if rl.IsKeyPressed(.SLASH) do g.debug_mode = !g.debug_mode
  if g.debug_mode {
    draw_shape(.DebugGrid, Vec3{100, 1, 0})

    if rl.IsKeyPressed(.R) {
      start_new_game()
    }
  }
}

reset_input :: proc() {
  g.mouse_position = rl.GetMousePosition()
  g.location_hover_id = none
  g.entity_hover_id = none
}

update_and_draw_locations :: proc() {
  current_location := get_current_location()

  for &location in w.locations.items {
    if box.skip(location) do continue
    if g.location_view_id != location.parent_id do continue

    #partial switch location.kind {
    case .System:
      draw_sprite(.Star, location.position)
    case .Planet:
      draw_sprite(.Planet, location.position)
    case .City:
      draw_sprite(.City, location.position)
    }

    // Hover
    screen_position, on_screen := to_screen_position(location.position)
    if on_screen && distance(g.mouse_position, screen_position) < 10 {
      g.location_hover_id = location.id
      ui.tooltip = location.name
      // TODO: Hover effect on location
      draw_sprite(.Planet, location.position)
      // rl.DrawSphereWires(location.position, 0.75, 6, 6, rl.GRAY)
    }

    // Draw connection routes
    if location.kind == .System {
      for conn_id in box.every(&location.connection_ids) {
        if location.id.idx > conn_id.idx do continue

        other_location := box.get(&w.locations, conn_id)
        draw_shape(.Line, location.position, other_location.position)
        // rl.DrawLine3D(location.position, other_location.position, rl.WHITE)
      }
    }

    // Draw planet orbit
    if location.kind == .Planet {
      distance := length(location.position - current_location.position)
      draw_shape(.CircleY, current_location.position, distance)
      // rl.DrawCircle3D(current_location.position, distance, Vec3{1, 0, 0}, 90, rl.WHITE)
    }
  }

  // Draw current location parent (star or planet)
  if current_location != nil {
    if current_location.kind == .System {
      draw_sprite(.Star, current_location.position)
    } else if current_location.kind == .Planet {
      draw_shape(.SphereWires, current_location.position, current_location.size)
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
    if box.skip(&company) do continue
  }
}

update_and_draw_entities :: proc() {
  current_location := get_current_location()

  for &entity in w.entities.items {
    if box.skip(&entity) do continue

    location := box.get(&w.locations, entity.location_id)
    if location == nil do continue

    if current_location == nil {
      // Looking for system
      location = location_find_parent(location, .System)
    } else if current_location.kind == .System {
      // Looking for planet/station
      location = location_find_parent(location, .Planet)
    } else if current_location.kind == .Planet {
      // Looking for city
      location = location_find_parent(location, .City)
    }

    if location == nil do continue
    location_screen_position, on_screen := to_screen_position(location.position)
    entity_screen_position := location_screen_position + Vec2{12, -12}

    if on_screen {
      draw_sprite(.Ship, entity_screen_position, rl.GREEN)
    }

    if on_screen && distance(g.mouse_position, entity_screen_position) < 10 {
      g.location_hover_id = none
      g.entity_hover_id = entity.id
      ui.tooltip = entity.name
      draw_sprite(.Planet, entity_screen_position)
    }

    if entity.id == g.entity_selected_id {
      for i := -2; i <= 2; i += 4 {
        for j := -2; j <= 2; j += 4 {
          draw_sprite(.Planet, entity_screen_position + Vec2{f32(i), f32(j)})
        }
      }
    }
  }
}

process_input :: proc() {
  current_location := get_current_location()
  is_left_click := rl.IsMouseButtonPressed(.LEFT)
  is_submit_command := rl.IsMouseButtonPressed(.RIGHT) && g.entity_selected_id != none
  is_go_back := rl.IsKeyPressed(.BACKSPACE)

  if is_left_click {
    if g.entity_hover_id != none {
      entity := box.get(&w.entities, g.entity_hover_id)
      if entity != nil {
        g.entity_selected_id = entity.id
      }
    } else if g.location_hover_id != none {
      if current_location == nil || current_location.kind != .Planet {
        location := box.get(&w.locations, g.location_hover_id)
        if location != nil {
          g.location_view_id = location.id
          g.camera.target = location.position
        }
      }
    } else {
      g.entity_selected_id = none
    }
  }

  if is_submit_command {
    if g.location_hover_id != none {
      entity := box.get(&w.entities, g.entity_selected_id)
      location := box.get(&w.locations, g.location_hover_id)
      if entity != nil && location != nil {
        prev_location := box.get(&w.locations, entity.location_id)
        is_same_location := prev_location.id == location.id
        if !is_same_location {
          // NOTE: compose a path for the flight here
          entity.position = prev_location.position
          entity.location_id = prev_location.parent_id
          entity.target_id = location.id
        }
      }
    }
  }

  if is_go_back {
    if current_location != nil && current_location.kind != .None {
      location := box.get(&w.locations, current_location.parent_id)
      if location != nil {
        g.location_view_id = location.id
        g.camera.target = location.position
      } else {
        g.location_view_id = none
        g.camera.target = current_location.position
      }
    }
  }
}
