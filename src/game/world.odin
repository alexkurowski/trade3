#+private
package game

import "deps:box"

Faction :: struct {
  id:   ID,
  name: string,
}

Location :: struct {
  id:             ID,
  kind:           LocationKind,
  name:           string,
  parent_id:      ID,
  connection_ids: box.Pool(ID, 4),
  faction_id:     ID,
  position:       Vec3,
  size:           f32,
}

LocationKind :: enum u8 {
  None,
  System,
  Planet,
  Facility,
  City,
  Station,
}

FACTION_COUNT :: 3
SYSTEM_COUNT :: 32

world: struct {
  factions:       box.Array(Faction, ID, FACTION_COUNT),
  locations:      box.Array(Location, ID, 1024),
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
}

reset_world :: proc() {
  // TODO: free all strings
  for &f in world.factions.items {
    if box.skip(&f) do continue
    delete(f.name)
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
  box.clear(&world.locations)
  box.clear(&world.entities)
  for kind in EntityKind {
    box.clear(&world.entity_by_kind[kind])
  }
}
