#+private
package game

GameState :: enum {
  Menu, // Main menu screen
  Upgrade, // Upgrade screen
  Run, // Main game loop
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
  case .Upgrade:
    state_upgrade_ready()
  case .Run:
    state_run_ready()
  }
}

state_update :: proc() {
  switch g.state {
  case .Menu:
    state_menu()
  case .Upgrade:
    state_upgrade()
  case .Run:
    state_run()
  case .Quit:
    break
  }
}

state_transition :: proc() {
  // TODO: animate state transision
}

