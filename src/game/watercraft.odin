#+private
package game

import "./render"
import rl "vendor:raylib"

update_watercraft :: proc(e: ^Entity) {

}

draw_watercraft :: proc(e: ^Entity) {
  render.shape(.Cube, to_vec3(e.position), Vec3{2, 0.5, 0.5} * e.size, rl.BLUE)
}
