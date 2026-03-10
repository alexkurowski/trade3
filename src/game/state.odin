#+private
package game

GameState :: enum {
  Menu,
  Map,
  Location,
  Pause,
  Quit,
}

@(private = "file")
transition: struct {
  next_state: GameState,
  timer:      f32,
}

set_state :: proc(state: GameState, immediate: bool = false) {
  g.state = state
}

state_transition :: proc() {
  // TODO: animate state transision
}
