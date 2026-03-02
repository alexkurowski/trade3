#+private
package game

import "./render"
import rl "vendor:raylib"

update_watercraft :: proc(e: ^Entity) {
  player_collision := rl.CheckCollisionCircleRec(
    g.player.position,
    g.player.size,
    rl.Rectangle{e.position.x - e.size * 2, e.position.y - e.size * 0.5, e.size * 2, e.size * 0.5},
  )

  if player_collision {
    if length(g.player.velocity) > 5 {
      render.shape(.Cube, to_vec3(e.position), Vec3{2, 0.5, 0.5} * e.size * 2, rl.RED)
    } else {
      g.player.position = Vec2 {
        g.player.position.x,
        e.position.y + 0.5 * e.size / 2 + g.player.position.y + g.player.size / 2,
      }
      g.player.velocity.y = 0
    }
  }

  draw_watercraft(e)
}

draw_watercraft :: proc(e: ^Entity) {
  render.shape(.Cube, to_vec3(e.position), Vec3{2, 0.5, 0.5} * e.size, rl.BLUE)
}
