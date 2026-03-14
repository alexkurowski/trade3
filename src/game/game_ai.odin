#+private
package game

import "physics"

ai_controls :: proc(e: ^Entity) {
  if g.player == nil do return

  dir := normalize(g.player.transform.position - e.transform.position)
  physics.push(e.body, to_vec2(dir) * 50)
}
