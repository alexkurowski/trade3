#+private
package game

import "deps:box"

Location :: struct {
  id:             ID,
  kind:           LocationKind,
  name:           string,
  parent_id:      ID,
  connection_ids: box.Pool(ID, 4),
  faction_id:     ID,
  position:       Vec3,
  size:           f32,
}

LocationKind :: enum u8 {
  World,
  System,
  Planet,
  Station,
  City,
}

get_current_location :: proc() -> ^Location {
  location := box.get(&w.locations, g.location_view_id)
  if location == nil {
    return &w.locations.items[0]
  } else {
    return location
  }
}

get_parent_location_kind :: proc(kind: LocationKind) -> Maybe(LocationKind) {
  if kind == .System do return nil
  if kind == .Planet do return .System
  if kind == .Station do return .System
  if kind == .City do return .Planet
  return nil
}

get_child_location_kind :: proc(kind: LocationKind) -> Maybe(LocationKind) {
  if kind == .World do return .System
  if kind == .System do return .Planet // or .Station
  if kind == .Planet do return .City
  if kind == .City do return nil
  return nil
}

location_find_parent :: proc(kind: LocationKind, id: ID) -> ^Location {
  loc := box.get(&w.locations, id)
  if loc == nil do return nil
  for loc.kind != kind {
    if loc.parent_id == none {
      return nil
    }
    loc = box.get(&w.locations, loc.parent_id)
  }
  return loc
}
