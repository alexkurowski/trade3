package main

import "../game"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

main :: proc() {
  game.open_window()
  defer game.close_window()

  game.load()
  defer game.unload()

  for game.is_running() {
    game.update()
  }
}

