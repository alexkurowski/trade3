package game

import "./render"
import "./text"
import "./ui"
import rl "vendor:raylib"
import gl "vendor:raylib/rlgl"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

GameMemory :: struct {
  debug: bool,
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
}

@(export)
close_window :: proc() {
  rl.CloseWindow()
}

@(export)
load :: proc() {
  g = new(GameMemory)
  g.debug = true

  text.load()
  render.load()
  ui.load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  // debug_init()

  start_new_game()
}

@(export)
unload :: proc() {
  ui.unload()
  render.unload()
  text.unload()

  free(g)
}

@(export)
is_running :: proc() -> bool {
  return !rl.WindowShouldClose()
}

@(export)
update :: proc() {
  rl.BeginDrawing()
  defer rl.EndDrawing()

  frame_begin()
  process_systems()
  process_events()
  // debug_update()
  frame_end()

  free_all(context.temp_allocator)
}

@(private)
start_new_game :: proc() {
  // despawn_all()
  // spawn_world()
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
  render.shapes_end()
  render.models_end()
  render.end_3d()

  render.begin_2d()
  render.sprites_end()
  ui.end()
  render.end_2d()
}
