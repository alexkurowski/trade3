#+private file
package game

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

  // TODO: scene switch
  world_update()

  process_input()
  camera_controls()

  draw_ui()

  debug_mode()
}

reset_input :: proc() {
  g.mouse_position = rl.GetMousePosition()
  g.location_hover_id = none
  g.entity_hover_id = none
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
    if current_location != nil && current_location.kind != .World {
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

debug_mode :: proc() {
  if rl.IsKeyPressed(.SLASH) do g.debug_mode = !g.debug_mode
  if g.debug_mode {
    draw_shape(.DebugGrid, Vec3{100, 1, 0})
    draw_sprite(.DebugFps, Vec2{0, 0})

    if rl.IsKeyPressed(.R) {
      start_new_game()
    }
  }
}
