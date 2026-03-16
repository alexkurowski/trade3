#+private
package game

import cont "containers"

Bullet :: struct {
  kind:     BulletKind,
  from:     BulletOwner,
  position: Vec3,
  velocity: Vec3,
  low:      bool,
}

BulletKind :: enum {
  None,
}

BulletOwner :: enum {
  Player,
  Enemy,
}

spawn_bullet :: proc(from: BulletOwner, position, velocity: Vec3, low: bool = false) {
  bullet := cont.append(
    &g.bullets,
    Bullet {
      from = from,
      position = position + normalize(velocity) / 2,
      velocity = velocity,
      low = low,
    },
  )
}

despawn_bullet :: proc(idx: i32) {
  cont.remove(&g.bullets, idx)
}

despawn_all_bullets :: proc() {
  cont.clear(&g.bullets)
}

