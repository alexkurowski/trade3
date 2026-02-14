package game

import "deps:box"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

g: struct {
  player_company_id:  ID,
  mouse_position:     Vec2,
  debug_mode:         bool,
  location_view_id:   ID,
  location_hover_id:  ID,
  entity_hover_id:    ID,
  entity_selected_id: ID,
} = {
  debug_mode = true,
}

load :: proc() {
  text_load()
  render_load()
  ui_load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  start_new_game()
}

unload :: proc() {
  ui_unload()
}

update :: proc() {
  render_begin_frame()
  time_step()

  ui_begin()

  render_begin_3d()
  scene_update_and_render()
  render_end_3d()

  render_begin_2d()
  draw_sprites()
  ui_end()
  render_end_2d()

  free_all(context.temp_allocator)
}
