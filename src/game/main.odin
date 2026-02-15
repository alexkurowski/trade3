package game

import "deps:box"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

// Global game state
g: struct {
  camera:             Camera,
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

// World state
w: struct {
  factions:       box.Array(Faction, ID, FACTION_COUNT),
  companies:      box.Array(Company, ID, COMPANY_COUNT),
  locations:      box.Array(Location, ID, 1024),
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
}

load :: proc() {
  text_load()
  assets_load()
  ui_load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  g.camera = new_camera()

  start_new_game()
}

unload :: proc() {
  ui_unload()
  assets_unload()
  world_cleanup()
}

update :: proc() {
  time_step()
  camera_step()

  shapes_begin()
  sprites_begin()
  ui_begin()

  game_update()

  render_begin_3d()
  shapes_end()
  render_end_3d()

  render_begin_2d()
  sprites_end()
  ui_end()
  render_end_2d()

  free_all(context.temp_allocator)
}
