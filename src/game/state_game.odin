#+private file
package game

import "physics"

@(private)
state_game :: proc() {
  process_systems()
  process_events()
}

@(private)
start_new_game :: proc() {
  despawn_all_entities()
  spawn_player()
  spawn_circle_at({1, 0, 0}, 0.6, 2)
  spawn_circle_at({0, 0, 2}, 1.2, 3)
  spawn_circle_at({-2, 0, 1}, 1.2, 4)
  spawn_box_at({-1, 0, -4}, 90 * DEG_TO_RAD, 5, 2, 0.5)
}

