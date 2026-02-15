#+private
package game

import "deps:box"

COMPANY_COUNT :: 64
FACTION_COUNT :: 3
SYSTEM_COUNT :: 32

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
