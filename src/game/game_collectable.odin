#+private
package game

import cont "containers"

Collectable :: struct {
  kind:     CollectableKind,
  position: Vec3,
  velocity: Vec3,
}

CollectableKind :: enum {
  None,
}

spawn_collectable_at :: proc(kind: CollectableKind, position: Vec3) {
  cont.append(&g.collectables, Collectable{kind = kind, position = to_vec3(position.xz)})
}

despawn_collectable :: proc(idx: i32) {
  cont.remove(&g.collectables, idx)
}

despawn_all_collectables :: proc() {
  cont.clear(&g.collectables)
}

