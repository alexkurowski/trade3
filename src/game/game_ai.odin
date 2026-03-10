#+private
package game

AiState :: enum {
  Idle,
  Roam,
  Hostile,
  Flee,
}

ai_controls :: proc(e: ^Entity) {
  switch e.ai.state {
  case .Idle:
  // NOP
  case .Roam:
  // TODO
  case .Hostile:
  // TODO
  case .Flee:
  // TODO
  }
}
