#+private
package game

import "deps:box"

Entity :: struct {
  id:             ID,
  kind:           EntityKind,
  trait:          bit_set[EntityTrait],
  location_id:    ID,
  connection_ids: [4]ID,
  parent_id:      ID,
  next_id:        ID,
  target_id:      ID,
  name:           string,
  position:       Vec3,
  velocity:       Vec3,
}

EntityKind :: enum u8 {
  None,
  Star,
  Planet,
  Station,
  Asteroid,
  Ship,
}

is_location :: proc(e: ^Entity) -> bool {
  return e.kind == .Star || e.kind == .Planet
}

EntityTrait :: enum u8 {
  None,
  BinaryStar,
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

//
//
//

entities: box.Array(Entity, ID, 8192)
entity_kind_cache: [EntityKind]box.Pool(ID, 1024)

player: struct {
  ship_id:          ID,
  view_location_id: ID,
  hover_id:         ID,
  selected_id:      ID,
}

//
//
//

ID :: box.ArrayItem
none :: ID{0, 0}
is_none :: #force_inline proc(id: ID) -> bool {
  return id == none
}
