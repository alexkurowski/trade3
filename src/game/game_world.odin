#+private
package game

import "./render"
import "./ui"
import "deps:box"

world_cleanup :: proc() {
  for &f in w.factions.items {
    if box.is_none(&f) do continue
    delete(f.name)
  }
  for &c in w.companies.items {
    if box.is_none(&c) do continue
    delete(c.name)
  }
  for &l in w.locations.items {
    if box.is_none(&l) do continue
    delete(l.name)
  }
  for &e in w.entities.items {
    if box.is_none(&e) do continue
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
    view_location := get_current_location()
    view_kind := view_location.kind

    for &location in w.locations.items {
      if box.is_none(location) do continue
      if g.location_view_id != location.parent_id && g.location_view_id != location.id do continue

      // Draw location sprite/shape
      {
        if location.kind == .System {
          render.sprite(.Star, location.position)
        }

        if location.kind == .Planet {
          if view_kind == .Planet {
            render.shape(.SphereWires, location.position, location.size)
          } else {
            render.sprite(.Planet, location.position)
            parent := box.get(&w.locations, location.parent_id)
            render.shape(.CircleY, parent.position, length(location.position - parent.position))
          }
        }

        if location.kind == .City {
          render.sprite(.City, location.position)
        }
      }

      // Hover
      screen_position, on_screen := to_screen_position(location.position)
      if on_screen && distance(g.mouse_position, screen_position) < 10 {
        g.location_hover_id = location.id
        ui.tooltip = location.name
        render.sprite(.Planet, location.position, 2, Color{255, 255, 255, 128})
      }

      // Draw connection routes
      if view_kind == .World && location.kind == .System {
        for conn_id in box.every(&location.connection_ids) {
          if location.id.idx > conn_id.idx do continue

          other_location := box.get(&w.locations, conn_id)
          render.shape(.Line, location.position, other_location.position)
          // rl.DrawLine3D(location.position, other_location.position, rl.WHITE)
        }
      }
    }
  }

  update_entities :: proc() {
    view_location := get_current_location()
    view_kind := view_location.kind

    for &entity in w.entities.items {
      if box.is_none(&entity) do continue

      {
        if entity.kind == .Vehicle {
          if entity.target_id != none {
            target := box.get(&w.locations, entity.target_id)
            entity.position += (target.position - entity.position) * time.wdt
            if distance(entity.position, target.position) < 0.1 {
              entity.position = target.position
              entity.location_id = target.id
              entity.target_id = none
            }
          }
        }
      }

      screen_position, on_screen := get_entity_screen_position(view_kind, &entity)
      if !on_screen do continue

      screen_position += Vec2{12, -12}
      render.sprite(.Ship, screen_position, Color{0, 255, 0, 255})

      if distance(g.mouse_position, screen_position) < 10 {
        g.location_hover_id = none
        g.entity_hover_id = entity.id
        ui.tooltip = entity.name
        render.sprite(.Planet, screen_position, 2, Color{255, 255, 255, 128})
      }

      if entity.id == g.entity_selected_id {
        render.sprite(.Planet, screen_position, 2, Color{255, 64, 64, 128})
      }
    }
  }

  update_companies :: proc() {
    for &company in w.companies.items {
      if box.is_none(&company) do continue
    }
  }

  update_factions :: proc() {

  }

  update_locations()
  update_entities()
  update_companies()
  update_factions()
}
