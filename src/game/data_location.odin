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
  None,
  System,
  Planet,
  Settlement,
  City,
  Station,
}

get_current_location :: proc() -> ^Location {
  return box.get(&w.locations, g.location_view_id)
}

location_find_parent :: proc(l: ^Location, kind: LocationKind) -> ^Location {
  loc := l
  for loc.kind != kind {
    if loc.parent_id == none {
      return nil
    }
    loc = box.get(&w.locations, loc.parent_id)
  }
  return loc
}
