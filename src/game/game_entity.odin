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

spawn :: proc(entity: Entity) -> ID {
  id := box.append(&world.entities, entity)
  box.append(&world.entity_by_kind[entity.kind], id)
  return id
}

despawn :: proc(id: ID) {
  entity := box.get(&world.entities, id)
  if entity.id == id {
    delete(entity.name)
    box.remove(&world.entity_by_kind[entity.kind], entity.cache_id)
    box.remove(&world.entities, id)
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
