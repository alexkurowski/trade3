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
