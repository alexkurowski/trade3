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
  Vehicle,
  Character,
}

EntityTrait :: enum u8 {
  None,
}

spawn :: proc(kind: EntityKind, entity: Entity) -> ID {
  e := entity
  e.kind = kind
  id := box.append(&w.entities, e)
  box.append(&w.entity_by_kind[kind], id)
  return id
}

despawn :: proc(id: ID) {
  e := box.get(&w.entities, id)
  if e.id == id {
    delete(e.name)
    box.remove(&w.entity_by_kind[e.kind], e.cache_id)
    box.remove(&w.entities, id)
  }
}


// Vehicle :: struct {
//   id:       ID,
//   location: ID,
//   name:     string,
//   kind:     VehicleKind,
//   fitting:  VehicleFitting,
//   cargo:    VehicleCargo,
// }
//
// VehicleKind :: enum u8 {
//   None,
//   Landcraft,
//   Aircraft,
//   Spacecraft,
// }
//
// VehicleFitting :: struct {}
//
// VehicleCargo :: struct {}
//
//
// Character :: struct {
//   id:       ID,
//   location: ID,
//   name:     string,
//   needs:    CharacterNeeds,
//   skills:   CharacterSkills,
// }
//
// CharacterNeeds :: struct {
//   food:  f32,
//   sleep: f32,
// }
//
// CharacterSkills :: struct {
//   combat:   f32,
//   repair:   f32,
//   piloting: f32,
// }
