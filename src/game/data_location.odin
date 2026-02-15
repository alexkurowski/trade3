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
