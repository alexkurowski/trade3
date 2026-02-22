package game

import "./render"
import "./text"
import "./ui"
import "core:strings"
import rl "vendor:raylib"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

load :: proc() {
  text.load()
  assets_load()
  ui.load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  camera_init()
  debug_init()

  start_new_game()
}

unload :: proc() {
  ui.unload()
  assets_unload()
}

start_new_game :: proc() {
  despawn_all()
  spawn(.Mothership, Entity{name = strings.clone("Mothership")})
  spawn(.Character, Entity{name = text.make_random_full_name()})
  spawn(.Character, Entity{name = text.make_random_full_name()})
}

update :: proc() {
  time_step()
  camera_step(&g.camera)
  camera_controls(&g.camera)
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
  g.mouse_position = rl.GetMousePosition()
  g.entity_hover_id = none
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

