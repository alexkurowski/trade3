#+private
package game

import "deps:box"

ObjectType :: enum {
  None,
  Location,
  Entity,
}

ObjectSelector :: struct {
  type: ObjectType,
  idx:  IDX,
}


Location :: struct {
  id:         IDX,
  kind:       LocationKind,
  trait:      LocationTrait,
  parent:     IDX,
  connection: [4]IDX,
  name:       string,
  position:   Vec3,
}

LocationKind :: enum u8 {
  None,
  Sector,
  Planet,
  Station,
}

LocationTrait :: enum u8 {
  None,
  BinaryStar,
}


Entity :: struct {
  id:       IDX,
  kind:     EntityKind,
  trait:    EntityTrait,
  location: IDX,
  parent:   IDX,
  next:     IDX,
  name:     string,
  position: Vec3,
  target:   ObjectSelector,
  velocity: Vec3,
}

EntityKind :: enum u8 {
  None,
  Asteroid,
  Ship,
}

EntityTrait :: enum u8 {
  None,
}


// Vehicle :: struct {
//   id:       IDX,
//   location: IDX,
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
//   id:       IDX,
//   location: IDX,
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

locations: box.Array(Location, IDX, 1024)
entities: box.Array(Entity, IDX, 8192)

player: struct {
  current_ship:     IDX,
  current_location: IDX,
  hover:            ObjectSelector,
  selected:         ObjectSelector,
}

//
//
//

IDX :: box.ArrayItem
none :: IDX{0, 0}
is_none :: #force_inline proc(idx: IDX) -> bool {
  return idx == none
}
