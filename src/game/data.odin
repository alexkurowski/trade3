#+private
package game

import "deps:box"

Location :: struct {
  id:         EID,
  kind:       LocationKind,
  parent:     EID,
  connection: [4]EID,
  name:       string,
  position:   Vec3,
}

LocationKind :: enum u8 {
  None,
  Sector,
  Planet,
  Station,
}


Entity :: struct {
  id:       EID,
  kind:     EntityKind,
  location: EID,
  parent:   EID,
  next:     EID,
  name:     string,
  position: Vec3,
}

EntityKind :: enum u8 {
  None,
  Landcraft,
  Spacecraft,
}


// Vehicle :: struct {
//   id:       EID,
//   location: EID,
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
//   id:       EID,
//   location: EID,
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

locations: box.Array(Location, EID, 1024)
entities: box.Array(Entity, EID, 8192)

//
//
//

EID :: box.ArrayItem
none :: EID{0, 0}
is_none :: #force_inline proc(eid: EID) -> bool {
  return eid == none
}
