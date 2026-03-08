#+private file
package game

@(private)
state_game :: proc() {
  process_systems()
  process_events()
}

@(private)
start_new_game :: proc() {
  despawn_all_entities()
  spawn_player()
  spawn_circle_at({1, 0, 0}, 0.3, 2)
  spawn_circle_at({0, 0, 2}, 0.3, 3)
  spawn_circle_at({-2, 0, 1}, 0.3, 4)
  spawn_box_at({-1, 0, -4}, 45 * DEG_TO_RAD, 5, 2, 0.5)
}
