#+private
package game

import "deps:box"

Entity :: struct {
  id:       ID,
  kind:     EntityKind,
  traits:   bit_set[EntityTrait],
  cache_id: i32,
  age:      f32,
  position: Vec2,
  size:     f32,
  rotation: f32,
  velocity: Vec2,
}

EntityKind :: enum u8 {
  Aircraft,
  Watercraft,
}

EntityTrait :: enum {
  None,
  Player,
  Hostile,
  Fleeing,
}

spawn :: proc(kind: EntityKind, entity: Entity) -> ID {
  e := entity
  e.kind = kind
  id, ok := box.append(&g.entities, e)
  if ok {
    box.append(&g.entity_by_kind[kind], id)
    return id
  } else {
    return none
  }
}

despawn :: proc(id: ID) {
  e := box.get(&g.entities, id)
  if e.id == id {
    box.remove(&g.entity_by_kind[e.kind], e.cache_id)
    box.remove(&g.entities, id)
  }
}

despawn_all :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue
    box.remove(&g.entity_by_kind[e.kind], e.cache_id)
  }
  box.clear(&g.entities)
  box.clear(&g.bullets)
  box.clear(&g.particles)
}
