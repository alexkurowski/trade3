#+private
package game

import "deps:box"

COMPANY_COUNT :: 64
FACTION_COUNT :: 3
SYSTEM_COUNT :: 32

World :: struct {
  factions:       box.Array(Faction, ID, FACTION_COUNT),
  companies:      box.Array(Company, ID, COMPANY_COUNT),
  locations:      box.Array(Location, ID, 1024),
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
}

world_cleanup :: proc() {
  for &f in w.factions.items {
    if box.skip(&f) do continue
    delete(f.name)
  }
  for &c in w.companies.items {
    if box.skip(&c) do continue
    delete(c.name)
  }
  for &l in w.locations.items {
    if box.skip(&l) do continue
    delete(l.name)
  }
  for &e in w.entities.items {
    if box.skip(&e) do continue
    despawn(e.id)
  }

  box.clear(&w.factions)
  box.clear(&w.companies)
  box.clear(&w.locations)
  box.clear(&w.entities)
  for kind in EntityKind {
    box.clear(&w.entity_by_kind[kind])
  }

  g.location_view_id = none
  g.location_hover_id = none
  g.entity_hover_id = none
  g.entity_selected_id = none
}

world_update :: proc() {
  update_locations :: proc() {
    current_location := get_current_location()

    for &location in w.locations.items {
      if box.skip(location) do continue
      if g.location_view_id != location.parent_id && g.location_view_id != location.id do continue

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
        draw_sprite(.Planet, location.position, 2, Color{255, 255, 255, 128})
      }

      // Draw connection routes
      if current_location == nil && location.kind == .System {
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
        // draw_sprite(.Star, current_location.position)
      } else if current_location.kind == .Planet {
        draw_shape(.SphereWires, current_location.position, current_location.size)
      }
    }
  }

  update_entities :: proc() {
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
        draw_sprite(.Ship, entity_screen_position, Color{0, 255, 0, 255})
      }

      if on_screen && distance(g.mouse_position, entity_screen_position) < 10 {
        g.location_hover_id = none
        g.entity_hover_id = entity.id
        ui.tooltip = entity.name
        draw_sprite(.Planet, entity_screen_position, 2, Color{255, 255, 255, 128})
      }

      if entity.id == g.entity_selected_id {
        draw_sprite(.Planet, entity_screen_position, 2, Color{255, 64, 64, 128})
      }
    }
  }

  update_companies :: proc() {
    for &company in w.companies.items {
      if box.skip(&company) do continue
    }
  }

  update_factions :: proc() {

  }

  update_locations()
  update_entities()
  update_companies()
  update_factions()
}
