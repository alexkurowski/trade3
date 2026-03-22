#+private
package game

import "physics"

spawn_enemy :: proc() {
  position := g.location.doors[randi(0, 1)]
  e := spawn_at(position + rand_offset(0, TILE_SIZE / 2))
  e.kind = {.Enemy}
  e.health = val(1)
  e.speed = val(10)
  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, 0.75, mass = 2, category = .Enemy)
}

enemy_controls :: proc(e: ^Entity) {
  if g.player == nil do return

  dir := normalize(g.player.transform.position - e.transform.position)
  physics.push(e.body, to_vec2(dir) * e.speed.current)
}

