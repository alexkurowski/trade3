#+private
package game

import "physics"

spawn_player :: proc() {
  player := spawn(Entity{})
  player.kind |= {.Player}
  physics.set_body_shape(&player.body, .Circle, 0.3, mass = 6)
  g.player_id = player.id
}

spawn_circle_at :: proc(position: Vec3, size, mass: f32) {
  e := spawn(Entity{position = position})
  physics.set_body_shape(&e.body, .Circle, size, mass = mass)
}

spawn_box_at :: proc(position: Vec3, rotation, width, height, mass: f32) {
  e := spawn(Entity{position = position, rotation = rotation})
  physics.set_body_shape(&e.body, .Box, width, height, mass = mass)
}

