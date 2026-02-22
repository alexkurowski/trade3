#+private
package game

import "deps:box"

// Global game state
g: struct {
  camera:             Camera,
  player_company_id:  ID,
  mouse_position:     Vec2,
  debug_mode:         bool,
  entity_hover_id:    ID,
  entity_selected_id: ID,
  entities:           box.Array(Entity, ID, 102400),
  entity_by_kind:     [EntityKind]box.Pool(ID, 1024),
} = {
  debug_mode = true,
}
