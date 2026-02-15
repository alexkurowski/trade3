#+private
package game

import "deps:box"

COMPANY_COUNT :: 64
FACTION_COUNT :: 3
SYSTEM_COUNT :: 32

// World state
w: struct {
  factions:       box.Array(Faction, ID, FACTION_COUNT),
  companies:      box.Array(Company, ID, COMPANY_COUNT),
  locations:      box.Array(Location, ID, 1024),
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
}

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
