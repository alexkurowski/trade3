#+private
package game

import "deps:box"

Entity :: struct {
  id:              ID,
  cache_id:        i32,
  kind:            EntityKind,
  trait:           bit_set[EntityTrait],
  company_id:      ID,
  location_id:     ID,
  parent_id:       ID,
  sibling_id:      ID,
  target_id:       ID,
  name:            string,
  position:        Vec3,
  target_position: Vec3,
}

EntityKind :: enum u8 {
  None,
  Location,
  Mothership,
  Vehicle,
  Character,
  Resource,
}

EntityTrait :: enum u8 {
  None,
  Location_Planet,
  Location_Station,
  Location_Asteroid,
}

spawn :: proc(kind: EntityKind, entity: Entity) -> ID {
  e := entity
  e.kind = kind
  id := box.append(&g.entities, e)
  box.append(&g.entity_by_kind[kind], id)
  return id
}

despawn :: proc(id: ID) {
  e := box.get(&g.entities, id)
  if e.id == id {
    delete(e.name)
    box.remove(&g.entity_by_kind[e.kind], e.cache_id)
    box.remove(&g.entities, id)
  }
}

despawn_all :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue
    delete(e.name)
  }
  box.clear(&g.entities)
}
