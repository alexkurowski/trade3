#+private
package game

import "deps:box"

Location :: struct {
  id:         EID,
  kind:       LocationKind,
  position:   Vec3,
  connection: [4]EID,
}

LocationKind :: enum u8 {
  None,
}


Vehicle :: struct {
  id:       EID,
  location: EID,
  kind:     VehicleKind,
  fitting:  VehicleFitting,
  cargo:    VehicleCargo,
}

VehicleKind :: enum u8 {
  None,
  Landcraft,
  Aircraft,
  Spacecraft,
}

VehicleFitting :: struct {}

VehicleCargo :: struct {}


Character :: struct {
  id:       EID,
  location: EID,
  needs:    CharacterNeeds,
  skills:   CharacterSkills,
}

CharacterNeeds :: struct {
  food:  f32,
  sleep: f32,
}

CharacterSkills :: struct {
  combat:   f32,
  repair:   f32,
  piloting: f32,
}

//
//
//

locations: box.Array(Location, EID, 4096)
vehicles: box.Array(Vehicle, EID, 4096)
characters: box.Array(Character, EID, 4096)

//
//
//

EID :: box.ArrayItem
none :: EID{0, 0}
is_none :: #force_inline proc(eid: EID) -> bool {
  return eid == none
}
