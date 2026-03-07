#+private
package game

import "./physics"
import "deps:box"
import "render"

process_systems :: proc() {
  time_step()
  physics.update(time.dt)

  for &e in g.entities.items {
    if box.is_none(e) do continue

    render.shape(.Sphere, e.position, e.body.size, {255, 255, 255, 255})
  }
}

