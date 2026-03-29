#+private
package game

import cont "containers"
import "physics"
import "render"

Entity :: struct {
  id:        ID,
  kind:      bit_set[EntityKind],
  age:       f32,
  body:      physics.Body,
  transform: struct {
    position: Vec3, // cached value from box2d
    velocity: Vec3, // cached value from box2d
    rotation: f32, // cached value from box2d
  },
  sprite:    struct {
    kind: render.SpriteKind,
    size: f32,
    flip: bool,
  },
  model:     struct {
    kind: render.ModelKind,
  },
  ai:        struct {
    state:  AiState,
    target: Vec3,
  },
  health:    EntityValue,
  speed:     EntityValue,
  weapon:    EntityWeapon,
  crouch:    bool,
  status:    [StatusKind]EntityValue,
}

EntityKind :: enum {
  None,
  Player,
  Enemy,
  EnemyMelee,
  EnemyShooter,
  // TODO: more enemy kinds
  WallSmall,
  // TODO: more obstacle kinds
}

EntityValue :: struct {
  current: f32,
  max:     f32,
}

StatusKind :: enum {
  None,
  Invincible,
}

AiState :: enum {
  None,
}

EntityWeapon :: struct {
  kind: WeaponKind,
  fire: struct {
    current:  f32,
    interval: f32,
  },
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

spawn_at_vec2 :: proc(position: Vec2, rotation: f32 = 0) -> ^Entity {
  return spawn(Entity{transform = {position = to_vec3(position), rotation = rotation}})
}
spawn_at_vec3 :: proc(position: Vec3, rotation: f32 = 0) -> ^Entity {
  return spawn(Entity{transform = {position = position, rotation = rotation}})
}
spawn_at :: proc {
  spawn_at_vec2,
  spawn_at_vec3,
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
    if is_none(e.id) do continue
    physics.destroy_body(e.body)
  }
  clear(&g.body_to_entity)
  cont.clear(&g.entities)
}

spawn_small_wall :: proc(position: Vec3, rotation: f32) {
  e := spawn_at(position, rotation)
  e.health = val(1000)
  e.model = {
    kind = .WallSmall00,
  }
  physics.set_body_shape(&e.body, .Box, 1.3, 0.8, mass = 500, category = .SemiObstacle)
}

// spawn_circle_at :: proc(position: Vec3, size, mass: f32) {
//   e := spawn(Entity{transform = {position = position}})
//   e.sprite = {
//     kind = .Character,
//     size = 1,
//   }
//   physics.set_body_shape(&e.body, .Circle, size, mass = mass, category = .Obstacle)
// }

// spawn_box_at :: proc(position: Vec3, rotation, width, height, mass: f32) {
//   e := spawn(Entity{transform = {position = position, rotation = rotation}})
//   physics.set_body_shape(&e.body, .Box, width, height, mass = mass, category = .Obstacle)
// }

//
//
//

val :: proc(value: f32) -> EntityValue {
  return EntityValue{value, value}
}

val_add :: proc(v: ^EntityValue, a: f32) {
  v.current += a
  v.max += a
}

hurt :: proc(e: ^Entity, value: f32) {
  if value > 0 {
    e.health.current -= value
    if e.id == g.player.id {
      send_event(.PlayerTookDamage, e.id)
    } else {
      send_event(.PlayerHitEnemy, e.id)
    }
  }
}

die :: proc(e: ^Entity) {
  if .Player in e.kind {
    set_state(.Upgrade)
  }
  if .Enemy in e.kind {
    spawn_collectable_at(.A, e.transform.position.xz, rand_offset(2, 4))
  }
}

set_status :: proc(e: ^Entity, status: StatusKind, duration: f32) {
  e.status[status].current = duration
  e.status[status].max = duration
}

add_status :: proc(e: ^Entity, status: StatusKind, duration: f32) {
  if e.status[status].max == 0 {
    e.status[status].max = duration
  }
  e.status[status].current = min(e.status[status].current + duration, e.status[status].max)
}

has_status :: proc(e: ^Entity, status: StatusKind) -> bool {
  return e.status[status].current > 0
}

