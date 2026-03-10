#+private
package game

import "deps:box"

Location :: struct {
  id:          ID,

  // World map
  position:    Grid2,
  offset:      Vec3,
  connections: box.Pool(ID, 4),

  // Mission map
  size:        u8,
  tiles:       [32][32]Tile,
}

Tile :: struct {
  kind:  TileKind,
  color: Color,
}

TileKind :: enum {
  None,
  Floor,
  Wall,
}
