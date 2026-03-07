#+private
package game

state_game :: proc() {
  process_systems()
  process_events()
}

start_new_game :: proc() {
  despawn_all_entities()
  spawn_player()
}

