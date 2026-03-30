#+private
package game

import cont "containers"
import "render"

Collectable :: struct {
  kind:     ResourceKind,
  amount:   u32,
  position: Vec3,
  velocity: Vec3,
  flip:     bool,
}

spawn_collectable_at :: proc(
  kind: ResourceKind,
  position: Vec2,
  velocity: Vec2 = Vec2(0),
  amount: u32 = 1,
) {
  cont.append(
    &g.collectables,
    Collectable {
      kind = kind,
      position = to_vec3(position),
      velocity = to_vec3(velocity),
      amount = amount,
      flip = position.x > 0 || position.y < 0,
    },
  )
}

spawn_collectable_crate :: proc() {
  cont.append(
    &g.collectables,
    Collectable{kind = .A, position = to_vec3(rand_offset(3, 5), 0), velocity = 0, amount = 10},
  )
}

despawn_collectable :: proc(idx: i32) {
  cont.remove(&g.collectables, idx)
}

despawn_all_collectables :: proc() {
  cont.clear(&g.collectables)
}

pickup_collectable :: proc(c: ^Collectable) {
  g.player.inventory.resources[c.kind] += u64(c.amount)
}
