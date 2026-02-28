package main

import "../game"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

main :: proc() {
  rl.SetConfigFlags({.MSAA_4X_HINT, .WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

  rl.InitWindow(game.INITIAL_WINDOW_WIDTH, game.INITIAL_WINDOW_HEIGHT, "Trade")
  defer rl.CloseWindow()

  rl.SetTargetFPS(90)
  rl.SetExitKey(.ESCAPE)
  gl.EnableDepthTest()
  gl.EnableColorBlend()
  gl.SetClipPlanes(0.5, 500)

  game.load()
  defer game.unload()

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    game.update()
    rl.EndDrawing()
  }
}

