#+private
package game

import "deps:box"
import "physics"
import "render"

Entity :: struct {
  id:        ID,
  kind:      bit_set[EntityKind],
  body:      physics.Body,
  transform: struct {
    position: Vec3, // cached value from box2d
    velocity: Vec3, // cached value from box2d
    rotation: f32, // cached value from box2d
  },
  health:    EntityValue,
  sprite:    struct {
    kind: render.SpriteKind,
    size: f32,
    flip: bool,
  },
}

EntityKind :: enum {
  None,
  Player,
  Enemy,
}

EntityValue :: struct {
  current: f32,
  max:     f32,
}


spawn :: proc(entity: Entity) -> ^Entity {
  id, ok := box.append(&g.entities, entity)
  if !ok do panic("Too many entities")

  e := box.get(&g.entities, id)
  e.body = physics.create_body()
  physics.set_position(e.body, to_vec2(e.transform.position), e.transform.rotation)
  return e
}

despawn :: proc(id: ID) {
  e := box.get(&g.entities, id)
  if e == nil do return

  physics.destroy_body(e.body)
  box.remove(&g.entities, id)
}

despawn_all_entities :: proc() {
  box.clear(&g.entities)
}
