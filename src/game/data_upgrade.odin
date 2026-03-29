#+private
package game

import cont "containers"
import "render"

Upgrade :: struct {
  id:        ID,
  kind:      UpgradeKind,
  icon:      render.UpgradeKind,
  parent_id: ID,
  current:   i32,
  price:     [ResourceKind]u32,
  max:       i32,
  position:  Vec2,
  apply:     proc(u: ^Upgrade, id: ID),
}

UpgradeKind :: enum {
  OnStart, // Apply when run begins
  OnHit, // Apply when player hits an enemy
  OnDamage, // Apply when player takes damage
}

UPGRADE_COUNT :: 16

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

  add :: proc(u: Upgrade, parent_idx_offset: u32 = 0, parent_position_offset: Vec2 = 0) {
    idx := g.progress.upgrades.num_items
    idx -= parent_idx_offset
    parent := g.progress.upgrades.items[idx]
    u := u
    u.parent_id = parent.id
    u.position = parent.position + parent_position_offset
    cont.append(&g.progress.upgrades, u)
  }

  // Root upgrade
  add(Upgrade {
    kind = .OnStart,
    icon = .Star,
    max = 5,
    price = price(A = 10),
    apply = proc(u: ^Upgrade, id: ID) {
      e := cont.get(&g.entities, id)
      if e == nil do return

      val_add(&e.health, 1 * f32(u.current))
    },
  })

  add(Upgrade {
    kind = .OnStart,
    icon = .Station,
    max = 3,
    price = price(A = 20),
    apply = proc(u: ^Upgrade, id: ID) {
      e := cont.get(&g.entities, id)
      if e == nil do return

      g.player.weapon.damage.current += 0.75 * f32(u.current)
    },
  }, 1, Vec2{32, 0})
  add(Upgrade {
    kind = .OnHit,
    icon = .Planet,
    max = 3,
    price = price(A = 20),
    apply = proc(u: ^Upgrade, id: ID) {
      e := cont.get(&g.entities, id)
      if e == nil do return

    },
  }, 2, Vec2{-32, -16})
  add(Upgrade {
    kind = .OnHit,
    icon = .City,
    max = 3,
    price = price(A = 40),
    apply = proc(u: ^Upgrade, id: ID) {
      e := cont.get(&g.entities, id)
      if e == nil do return

    },
  }, 3, Vec2{-32, 16})
}

apply_upgrades :: proc() {
  for &u in g.progress.upgrades.items {
    if is_none(u.id) do continue
    if !upgrade_is_active(&u) do continue
    switch u.kind {
    case .OnStart:
      u.apply(&u, g.player.id)
    case .OnHit:
      subscribe_event(.PlayerHitEnemy, u.id)
    case .OnDamage:
      subscribe_event(.PlayerTookDamage, u.id)
    }
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

upgrade_purchase :: proc(u: ^Upgrade) {
  g.progress.inventory.resources[.A] -= u64(u.price[.A])
  g.progress.inventory.resources[.B] -= u64(u.price[.B])
  g.progress.inventory.resources[.C] -= u64(u.price[.C])
  g.progress.inventory.resources[.D] -= u64(u.price[.D])
  g.progress.inventory.resources[.E] -= u64(u.price[.E])
  g.progress.inventory.resources[.F] -= u64(u.price[.F])
  u.current += 1
}

