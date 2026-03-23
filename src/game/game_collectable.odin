#+private
package game

import cont "containers"

Collectable :: struct {
  kind:     ResourceKind,
  amount:   u32,
  position: Vec3,
  velocity: Vec3,
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
    },
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

