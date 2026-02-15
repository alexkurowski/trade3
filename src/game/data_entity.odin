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

get_entity_screen_position :: proc(view_kind: LocationKind, e: ^Entity) -> (Vec2, bool) {
  // Get kind of the location this entity will be next to
  // If we're looking at top map, it's a system
  // If we're looking at a system, it's a planet
  child_kind, child_kind_ok := get_child_location_kind(view_kind).?
  if !child_kind_ok do return Vec2(0), false

  // Get parent location of the entity with correct kind
  parent_location := location_find_parent(child_kind, e.location_id)
  if parent_location == nil do return Vec2(0), false

  return to_screen_position(parent_location.position)
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
