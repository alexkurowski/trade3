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
  price:     [ResourceKind]u32,
  max:       i32,
  position:  Vec2,
}

UpgradeKind :: enum {
  None,
  Damage,
}

prepare_upgrades :: proc() {
  price :: proc(
    A: u32 = 0,
    B: u32 = 0,
    C: u32 = 0,
    D: u32 = 0,
    E: u32 = 0,
    F: u32 = 0,
  ) -> [ResourceKind]u32 {
    return [ResourceKind]u32{.A = A, .B = B, .C = C, .D = D, .E = E, .F = F}
  }

  // TODO: define upgrades here
  cont.append(&g.progress.upgrades, Upgrade{max = 5, price = price(A = 10)})
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

upgrade_is_complete :: proc(u: ^Upgrade) -> bool {
  return u.current >= u.max
}

upgrade_is_known :: proc(u: ^Upgrade) -> bool {
  if is_none(u.parent_id) do return true
  parent := cont.get(&g.progress.upgrades, u.parent_id)
  return upgrade_is_active(parent)
}

upgrade_can_afford :: proc(u: ^Upgrade) -> bool {
  return(
    g.progress.inventory.resources[.A] >= u64(u.price[.A]) &&
    g.progress.inventory.resources[.B] >= u64(u.price[.B]) &&
    g.progress.inventory.resources[.C] >= u64(u.price[.C]) &&
    g.progress.inventory.resources[.D] >= u64(u.price[.D]) &&
    g.progress.inventory.resources[.E] >= u64(u.price[.E]) &&
    g.progress.inventory.resources[.F] >= u64(u.price[.F]) \
  )
}

