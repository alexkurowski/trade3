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
  tiles:       [16][16]Tile,
}

Tile :: struct {}
