#+private
package game

import "deps:box"

// Global game state
g: struct {
  debug_mode:     bool,
  camera:         Camera,
  player_id:      ID,
  entities:       box.Array(Entity, ID, 102400),
  entity_by_kind: [EntityKind]box.Pool(ID, 1024),
  bullets:        box.Pool(Bullet, 4096),
  particles:      box.Pool(Particle, 4096),
} = {
  debug_mode = true,
}
