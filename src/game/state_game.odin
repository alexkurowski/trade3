#+private
package game

import "physics"

state_game :: proc() {
  process_systems()
  process_events()
}

start_new_game :: proc() {
  despawn_all_entities()
  spawn_player()
  {
    e := spawn(Entity{position = {1, 0, 0}})
    physics.set_body_shape(&e.body, .Circle, 0.6, mass = 2)
  }
  {
    e := spawn(Entity{position = {0, 0, 2}})
    physics.set_body_shape(&e.body, .Circle, 1.2, mass = 3)
  }
  {
    e := spawn(Entity{position = {-2, 0, 1}})
    physics.set_body_shape(&e.body, .Circle, 1.2, mass = 3)
  }
  {
    e := spawn(Entity{position = {-1, 0, -2}})
    physics.set_body_shape(&e.body, .Box, 5, 2, mass = 0.5)
  }
}


@(private = "file")
spawn_player :: proc() {
  player := spawn(Entity{kind = .Player})
  physics.set_body_shape(&player.body, .Circle, 0.6, mass = 4)
  g.player_id = player.id
}

