#+private
package game

import cont "containers"

Bullet :: struct {
  kind:     BulletKind,
  position: Vec3,
  velocity: Vec3,
}

BulletKind :: enum {
  None,
}

despawn_all_bullets :: proc() {
  cont.clear(&g.bullets)
}

