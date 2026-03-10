#+private
package game

import "deps:box"

generate_map :: proc() {
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
  return l
}

generate_tilemap :: proc(l: ^Location) {
  size := randi(8, 16)
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
}
