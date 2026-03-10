#+private
package game

import "deps:box"
import "physics"
import b2 "vendor:box2d"

TILE_SIZE :: 2

Location :: struct {
  id:          ID,

  // World map
  position:    Grid2,
  offset:      Vec3,
  connections: box.Pool(ID, 4),

  // Mission map
  size:        u8,
  tiles:       [32][32]Tile,
  body:        physics.BID,
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


generate_locations :: proc() {
  reset_locations()

  for i := i32(0); i < 8; i += 1 {
    for j := i32(0); j < 8; j += 1 {
      l := generate_location()
      l.position.x = i
      l.position.y = j
      box.append(&g.locations, l)
    }
  }

  g.location_id = g.locations.items[1].id
  g.current_location = box.get(&g.locations, g.location_id)
}

reset_locations :: proc() {
  for &l in g.locations.items {
    if box.is_none(l) do continue
    // delete location allocated stuff
  }

  box.clear(&g.locations)
}

generate_location :: proc() -> Location {
  l := Location{}
  generate_tilemap(&l)
  generate_physics(&l)
  return l
}

generate_tilemap :: proc(l: ^Location) {
  size :: 16 // randi(8, 32)
  l.size = u8(size)

  // Place floor
  for i := i32(0); i < size; i += 1 {
    for j := i32(0); j < size; j += 1 {
      l.tiles[i][j] = {
        kind  = .Floor,
        color = {40, 100, 200, 255},
      }
    }
  }

  // Place some walls
  for i := i32(0); i < size; i += 1 {
    l.tiles[0][i] = {
      kind  = .Wall,
      color = {75, 75, 75, 255},
    }
    l.tiles[i][0] = {
      kind  = .Wall,
      color = {75, 75, 75, 255},
    }
  }
  l.tiles[1][1] = {
    kind  = .Wall,
    color = {75, 75, 75, 255},
  }
  l.tiles[5][4] = {
    kind  = .Wall,
    color = {140, 140, 140, 255},
  }
  l.tiles[4][5] = {
    kind  = .Wall,
    color = {140, 140, 140, 255},
  }
}

generate_physics :: proc(l: ^Location) {
  l.body = physics.create_body().bid
  b2.Body_SetType(l.body, .staticBody)

  size := i32(l.size)
  tile_size :: TILE_SIZE / 2

  for i := i32(0); i < size; i += 1 {
    for j := i32(0); j < size; j += 1 {
      if l.tiles[i][j].kind == .Wall {
        shape_def := b2.DefaultShapeDef()
        polygon := b2.MakeOffsetBox(
          tile_size,
          tile_size,
          Vec2{f32(i * TILE_SIZE) + 0.5, f32(j * TILE_SIZE)},
          b2.Rot{1, 0},
        )
        _ = b2.CreatePolygonShape(l.body, shape_def, polygon)
      }
    }
  }
}
