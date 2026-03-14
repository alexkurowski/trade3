package main

import "../game"

main :: proc() {
  game.open_window()
  defer game.close_window()

  game.load()
  defer game.unload()

  for game.is_running() {
    game.update()
  }
}

// Make game use good GPU on laptops.
@(export)
NvOptimusEnablement: u32 = 1
@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
