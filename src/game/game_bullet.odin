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

spawn_bullet :: proc(position, velocity: Vec3) {
  bullet := cont.append(
    &g.bullets,
    Bullet{position = position + normalize(velocity), velocity = velocity},
  )
}

despawn_bullet :: proc(idx: i32) {
  cont.remove(&g.bullets, idx)
}

despawn_all_bullets :: proc() {
  cont.clear(&g.bullets)
}

