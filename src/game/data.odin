#+private
package game

import "deps:box"

Entity :: struct {
  id:        ID,
  kind:      EntityKind,
  traits:    bit_set[EntityTrait],
  cache_id:  i32,
  age:       f32,
  position:  Vec2,
  velocity:  Vec2,
  rotation:  f32,
  direction: f32, // -1 left to 1 right
}

EntityKind :: enum u8 {
  None,
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
  }
  box.clear(&g.entities)
  box.clear(&g.bullets)
  box.clear(&g.particles)
}

//
//
//

Bullet :: struct {
  kind:         BulletKind,
  position:     Vec2,
  velocity:     Vec2,
  acceleration: Vec2,
}

BulletKind :: enum {
  None,
  Small,
}

spawn_bullet :: proc(kind: BulletKind, position: Vec2, velocity: Vec2) {
  box.append(&g.bullets, Bullet{kind = kind, position = position, velocity = velocity})
}

//
//
//

Particle :: struct {
  kind:         ParticleKind,
  position:     Vec2,
  velocity:     Vec2,
  acceleration: Vec2,
  size:         f32,
  lifetime:     f32,
}

ParticleKind :: enum {
  None,
  Cloud,
  AircraftTrail,
}

spawn_particle :: proc(
  kind: ParticleKind,
  position: Vec2,
  velocity: Vec2,
  size: f32,
  lifetime: f32,
) {
  box.append(
    &g.particles,
    Particle {
      kind = kind,
      position = position,
      velocity = velocity,
      size = size,
      lifetime = lifetime,
    },
  )
}
