#+private
package game

import "deps:box"

Bullet :: struct {
  kind:         BulletKind,
  position:     Vec2,
  velocity:     Vec2,
  acceleration: Vec2,
}

BulletKind :: enum {
  None,
  Small,
}

spawn_bullet :: proc(kind: BulletKind, position: Vec2, velocity: Vec2) {
  box.append(&g.bullets, Bullet{kind = kind, position = position, velocity = velocity})
}
