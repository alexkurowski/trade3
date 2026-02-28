package game

import "./render"
import "./text"
import "./ui"
// import "core:strings"
// import rl "vendor:raylib"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

@(export)
load :: proc() {
  text.load()
  assets_load()
  ui.load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  camera_init()
  debug_init()

  start_new_game()
}

@(export)
unload :: proc() {
  ui.unload()
  assets_unload()
}

@(export)
start_new_game :: proc() {
  despawn_all()
  spawn_world()
}

@(export)
update :: proc() {
  time_step()
  camera_step()
  reset_input()

  frame_begin()
  update_world()
  draw_screen()
  process_events()
  debug_update()
  frame_end()

  free_all(context.temp_allocator)
}

@(private = "file")
frame_begin :: proc() {
  render.shapes_begin()
  render.sprites_begin()
  ui.begin(time.dt)
}

@(private = "file")
reset_input :: proc() {
}

@(private = "file")
frame_end :: proc() {
  render.begin_3d(g.camera.c3d, assets.shaders.base)
  render.shapes_end()
  render.end_3d()

  render.begin_2d()
  render.sprites_end(assets.textures.icons)
  ui.end()
  render.end_2d()
}
