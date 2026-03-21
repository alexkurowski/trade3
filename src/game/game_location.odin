#+private
package game

import cont "containers"

MAP_SIZE :: 32
TILE_SIZE :: 1
TILE_OFFSET :: -(MAP_SIZE * TILE_SIZE) / 2

Location :: struct {
  tiles: [MAP_SIZE][MAP_SIZE]Tile,
}

Tile :: struct {
  kind: TileKind,
}

TileKind :: enum {
  None,
  Floor,
  Wall,
  DoorWall,
  DoorFloor,
}

generate_location :: proc() {
  width, height: i32
  for width * height < MAP_SIZE {
    width = randi(4, MAP_SIZE / 2 - 2)
    height = randi(4, MAP_SIZE / 2 - 2)
  }

  x_a := MAP_SIZE / 2 - width
  x_b := MAP_SIZE / 2 + width
  y_a := MAP_SIZE / 2 - height
  y_b := MAP_SIZE / 2 + height

  tiles: [MAP_SIZE][MAP_SIZE]Tile
  potential_door_positions: cont.Pool([2]i32, MAP_SIZE * 4)

  kind_at :: proc(tiles: ^[MAP_SIZE][MAP_SIZE]Tile, i, j: i32) -> TileKind {
    if i < 0 || j < 0 || i >= MAP_SIZE || j >= MAP_SIZE {
      return .None
    }
    return tiles[i][j].kind
  }

  is_visible_wall :: proc(tiles: ^[MAP_SIZE][MAP_SIZE]Tile, i, j: i32) -> bool {
    return(
      kind_at(tiles, i + 1, j) == .Floor ||
      kind_at(tiles, i, j + 1) == .Floor ||
      kind_at(tiles, i + 1, j + 1) == .Floor \
    )
  }

  count_around :: proc(tiles: ^[MAP_SIZE][MAP_SIZE]Tile, i, j: i32, kind: TileKind) -> i32 {
    count := i32(0)
    for x := i32(-1); x <= 1; x += 1 {
      for y := i32(-1); y <= 1; y += 1 {
        if kind_at(tiles, i + x, j + y) == kind {
          count += 1
        }
      }
    }
    return count
  }

  // Place floor
  for i := i32(0); i < MAP_SIZE; i += 1 {
    for j := i32(0); j < MAP_SIZE; j += 1 {
      if i >= x_a && i <= x_b && j >= y_a && j <= y_b {
        tiles[i][j].kind = .Floor
      } else {
        tiles[i][j].kind = .None
      }
    }
  }

  // Add walls on two sides
  for i := i32(0); i < MAP_SIZE; i += 1 {
    for j := i32(0); j < MAP_SIZE; j += 1 {
      if tiles[i][j].kind != .None do continue

      if is_visible_wall(&tiles, i, j) {
        tiles[i][j].kind = .Wall
      }

      floors_around := count_around(&tiles, i, j, .Floor)
      if floors_around >= 3 {
        cont.append(&potential_door_positions, [2]i32{i, j})
      }
    }
  }

  shuffle(cont.every(&potential_door_positions))
  for i := 0; i < 2; i += 1 {
    pos := cont.pop(&potential_door_positions)
    if is_visible_wall(&tiles, pos.x, pos.y) {
      tiles[pos.x][pos.y].kind = .DoorWall
    } else {
      tiles[pos.x][pos.y].kind = .DoorFloor
    }
  }

  g.location.tiles = tiles
}

