#+private
package game

import "./physics"
import "deps:box"

Entity :: struct {
  id:       ID,
  body:     physics.Body,
  position: Vec3,
  rotation: f32,
}

EntityKind :: enum {
  Player,
  Enemy,
}


spawn :: proc(entity: Entity) -> ^Entity {
  id, ok := box.append(&g.entities, entity)
  if !ok do panic("Too many entities")

  e := box.get(&g.entities, id)
  e.body = physics.create_body()
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


spawn_player :: proc() {
  player := spawn(Entity{})
  physics.set_body_shape(&player.body, .Circle, 0.6, mass = 1)
  g.player_id = player.id
}

