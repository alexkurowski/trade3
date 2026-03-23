#+private
package game

import cont "containers"

UPGRADE_COUNT :: 16

Progress :: struct {
  inventory:     Inventory,
  upgrades:      cont.Array(Upgrade, ID, UPGRADE_COUNT),
  pickup_radius: f32,
}

ResourceKind :: enum {
  A,
  B,
  C,
  D,
  E,
  F,
}

Inventory :: struct {
  resources: [ResourceKind]u64,
}

Upgrade :: struct {
  id:        ID,
  kind:      UpgradeKind,
  parent_id: ID,
  current:   i32,
  max:       i32,
  offset:    Vec2, // Offset from parent
}

UpgradeKind :: enum {
  None,
  // TODO
}

prepare_upgrades :: proc() {
  // TODO: define upgrades here
}

progress_save_to_file :: proc() {
  // TODO: save progress into g.save_slot file
}

progress_load_from_file :: proc(save_slot: u32) {
  success := true
  // TODO: restore progress

  if success {
    g.save_slot = save_slot
  }
}

upgrade_is_active :: proc(u: ^Upgrade) -> bool {
  return u.current > 0
}

upgrade_is_known :: proc(u: ^Upgrade) -> bool {
  if u.id.idx == 1 do return true
  parent := cont.get(&g.progress.upgrades, u.parent_id)
  return upgrade_is_active(parent)
}

