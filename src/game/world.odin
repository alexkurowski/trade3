#+private file
package game

import "deps:box"

@(private)
update_world :: proc() {
  update_entities()
}

update_entities :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue

  }
}

