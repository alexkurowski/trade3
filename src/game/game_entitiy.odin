#+private
package game

import cont "containers"
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
  // ai:        struct {
  //   state: AiState,
  // },
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
  id, ok := cont.append(&g.entities, entity)
  if !ok do panic("Too many entities")

  e := cont.get(&g.entities, id)
  e.body = physics.create_body()
  physics.set_position(e.body, to_vec2(e.transform.position), e.transform.rotation)
  g.body_to_entity[e.body.bid] = e.id

  return e
}

despawn :: proc(id: ID) {
  e := cont.get(&g.entities, id)
  if e == nil do return

  physics.destroy_body(e.body)
  delete_key(&g.body_to_entity, e.body.bid)
  cont.remove(&g.entities, id)
}

despawn_all_entities :: proc() {
  for &e in g.entities.items {
    if cont.is_none(e) do continue
    physics.destroy_body(e.body)
  }
  clear(&g.body_to_entity)
  cont.clear(&g.entities)
}

hurt :: proc(e: ^Entity, value: f32) {
  if value > 0 {
    e.health.current -= value
    if e.health.current <= 0 {
      send_event(.GotKilled, Event_Entity{id = e.id})
    } else {
      send_event(.GotHurt, Event_Entity{id = e.id})
    }
  }
}

spawn_player :: proc() {
  player := spawn(Entity{transform = {position = {6, 0, 6}}})
  player.kind |= {.Player}
  player.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&player.body, .Circle, 0.3, mass = 6, category = .Player)
  g.player_id = player.id
}

spawn_enemy :: proc() {
  enemy := spawn(Entity{transform = {position = to_vec3(at_random_angle(25))}})
  enemy.kind |= {.Enemy}
  enemy.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&enemy.body, .Circle, 0.3, mass = 6, category = .Enemy)
}

spawn_circle_at :: proc(position: Vec3, size, mass: f32) {
  e := spawn(Entity{transform = {position = position}})
  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, size, mass = mass, category = .Obstacle)
}

spawn_box_at :: proc(position: Vec3, rotation, width, height, mass: f32) {
  e := spawn(Entity{transform = {position = position, rotation = rotation}})
  physics.set_body_shape(&e.body, .Box, width, height, mass = mass, category = .Obstacle)
}

