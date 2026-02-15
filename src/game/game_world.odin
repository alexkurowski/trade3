#+private
package game

import "deps:box"

COMPANY_COUNT :: 64
FACTION_COUNT :: 3
SYSTEM_COUNT :: 32

world: struct {
  factions:       box.Array(Faction, ID, FACTION_COUNT),
  companies:      box.Array(Company, ID, COMPANY_COUNT),
  locations:      box.Array(Location, ID, 1024),
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
}

world_Clear :: proc() {
  for &f in world.factions.items {
    if box.skip(&f) do continue
    delete(f.name)
  }
  for &c in world.companies.items {
    if box.skip(&c) do continue
    delete(c.name)
  }
  for &l in world.locations.items {
    if box.skip(&l) do continue
    delete(l.name)
  }
  for &e in world.entities.items {
    if box.skip(&e) do continue
    despawn(e.id)
  }

  box.clear(&world.factions)
  box.clear(&world.companies)
  box.clear(&world.locations)
  box.clear(&world.entities)
  for kind in EntityKind {
    box.clear(&world.entity_by_kind[kind])
  }

  g.location_view_id = none
  g.location_hover_id = none
  g.entity_hover_id = none
  g.entity_selected_id = none
}
