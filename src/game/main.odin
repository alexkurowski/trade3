package game

import "deps:box"
import "physics"
import "render"
import "text"
import "ui"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

GameMemory :: struct {
  state:     GameState,
  entities:  box.Array(Entity, ID, 2048),
  player_id: ID,
  player: ^Entity,
  debug:     bool,
}

g: ^GameMemory

@(export)
open_window :: proc() {
  rl.SetConfigFlags({.MSAA_4X_HINT, .WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

  rl.InitWindow(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT, "Garden")

  rl.SetTargetFPS(90)
  rl.SetExitKey(.ESCAPE)
  gl.EnableDepthTest()
  gl.EnableColorBlend()
  gl.SetClipPlanes(0.5, 500)

  // TODO: draw static loading screen
}

@(export)
close_window :: proc() {
  rl.CloseWindow()
}

@(export)
is_running :: proc() -> bool {
  return !rl.WindowShouldClose() && g.state != .Quit
}

@(export)
load :: proc() {
  g = new(GameMemory)
  g.debug = true

  text.load()
  render.load()
  ui.load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)
  physics.load()
}

@(export)
unload :: proc() {
  physics.unload()
  ui.unload()
  render.unload()
  text.unload()

  free(g)
}

@(export)
update :: proc() {
  rl.BeginDrawing()
  defer rl.EndDrawing()

  frame_begin()
  switch g.state {
  case .Menu:
    state_menu()
  case .Map:
    state_map()
  case .Run:
    state_run()
  case .Pause:
    state_pause()
  case .Quit:
    break
  }
  state_transition()
  frame_end()

  free_all(context.temp_allocator)
}

@(private = "file")
frame_begin :: proc() {
  render.begin(time.dt)
  ui.begin(time.dt)

  rl.ClearBackground(rl.BLACK)
}

@(private = "file")
frame_end :: proc() {
  render.begin_3d()
  render.draw_3d()

  if g.debug {
    physics.draw_debug()
  }

  render.end_3d()

  render.begin_2d()
  render.draw_2d()
  ui.end()
  render.end_2d()

  if rl.IsKeyPressed(.SLASH) {
    g.debug = !g.debug
  }
  if g.debug {
    rl.DrawFPS(0, 0)
  }
}
