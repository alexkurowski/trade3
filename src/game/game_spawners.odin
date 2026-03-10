#+private
package game

import "physics"

start_new_game :: proc() {
  despawn_all_entities()
  spawn_player()
  spawn_circle_at({1, 0, 0}, 0.3, 2)
  spawn_circle_at({0, 0, 2}, 0.3, 3)
  spawn_circle_at({-2, 0, 1}, 0.3, 4)
  spawn_box_at({-1, 0, -4}, 45 * DEG_TO_RAD, 5, 2, 0.5)
  generate_map()
}

spawn_player :: proc() {
  player := spawn(Entity{})
  player.kind |= {.Player}
  player.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&player.body, .Circle, 0.3, mass = 6)
  g.player_id = player.id
}

spawn_circle_at :: proc(position: Vec3, size, mass: f32) {
  e := spawn(Entity{transform = {position = position}})
  e.sprite = {
    kind = .Character,
    size = 1,
  }
  physics.set_body_shape(&e.body, .Circle, size, mass = mass)
}

spawn_box_at :: proc(position: Vec3, rotation, width, height, mass: f32) {
  e := spawn(Entity{transform = {position = position, rotation = rotation}})
  physics.set_body_shape(&e.body, .Box, width, height, mass = mass)
}
