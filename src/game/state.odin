#+private
package game

GameState :: enum {
  Menu,
  Map,
  Run,
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
  #partial switch state {
  case .Menu:
    state_menu_ready()
  case .Run:
    state_run_ready()
  }
}

state_transition :: proc() {
  // TODO: animate state transision
}

