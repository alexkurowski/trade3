#+private
package game

import cont "containers"
import "render"

Upgrade :: struct {
  id:         ID,
  kind:       UpgradeKind,
  trigger:    UpgradeTrigger,
  icon:       render.UpgradeKind,
  parent_id:  ID,
  price:      UpgradePrice,
  price_step: u32,
  current:    u32,
  max:        u32,
  position:   Vec2,
  apply:      UpgradeApplyFn,
}

UpgradePrice :: [ResourceKind]u32
UpgradeApplyFn :: #type proc(u: ^Upgrade, id: ID)

UpgradeKind :: enum {
  Health,
  Damage,
  Accuracy,
}

UpgradeTrigger :: enum {
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
  ) -> UpgradePrice {
    return UpgradePrice{.A = A, .B = B, .C = C, .D = D, .E = E, .F = F}
  }

  Direction :: enum {
    None,
    Right,
    Left,
    Up,
    Down,
    UpRight,
    UpLeft,
    DownRight,
    DownLeft,
  }
  add :: proc(
    kind: UpgradeKind = .Health,
    trigger: UpgradeTrigger = .OnStart,
    icon: render.UpgradeKind = .Star,
    price: UpgradePrice,
    price_step: u32 = 0,
    max: u32 = 3,
    parent: u32 = 0,
    dir: Direction = .Right,
    offset: Vec2 = 0,
    apply: UpgradeApplyFn,
  ) {
    idx := g.progress.upgrades.num_items
    idx -= parent
    parent := g.progress.upgrades.items[idx]

    in_direction: Vec2
    switch dir {
    case .None:
      in_direction = 0
    case .Left:
      in_direction = Vec2{-32, 0}
    case .Right:
      in_direction = Vec2{32, 0}
    case .Up:
      in_direction = Vec2{0, -32}
    case .Down:
      in_direction = Vec2{0, 32}
    case .UpLeft:
      in_direction = Vec2{-32, -32}
    case .UpRight:
      in_direction = Vec2{32, -32}
    case .DownLeft:
      in_direction = Vec2{-32, 32}
    case .DownRight:
      in_direction = Vec2{32, 32}
    }

    cont.append(
      &g.progress.upgrades,
      Upgrade {
        kind = kind,
        trigger = trigger,
        icon = icon,
        price = price,
        price_step = price_step,
        max = max,
        parent_id = parent.id,
        position = parent.position + in_direction + offset,
        apply = apply,
      },
    )
  }

  // Root upgrade
  add(
    kind = .Health,
    trigger = .OnStart,
    icon = .Star,
    max = 5,
    price = price(A = 10),
    price_step = 0,
    apply = proc(u: ^Upgrade, id: ID) {
      // health + V
      e := cont.get(&g.entities, id)
      if e == nil do return

      v := 1 * f32(u.current)
      e.health.current += v
      e.health.max += v
    },
    dir = .None,
  )

  add(
    kind = .Damage,
    trigger = .OnStart,
    icon = .Station,
    max = 3,
    price = price(A = 20),
    price_step = 20,
    apply = proc(u: ^Upgrade, id: ID) {
      // Damage + 0.75 * V
      v := 0.75 * f32(u.current)
      g.player.weapon.damage.current += v
    },
    parent = 1,
    dir = .Right,
  )
  add(
    kind = .Accuracy,
    trigger = .OnStart,
    icon = .Planet,
    max = 3,
    price = price(A = 20),
    apply = proc(u: ^Upgrade, id: ID) {
      // Sway cooldown - 0.99-0.95
      f := 1 - 0.01 * f32(u.current)
      g.player.weapon.sway.interval *= f
    },
    parent = 2,
    dir = .DownLeft,
  )

  add(
    kind = .Accuracy,
    trigger = .OnStart,
    icon = .City,
    max = 3,
    price = price(A = 40),
    apply = proc(u: ^Upgrade, id: ID) {
      // Sway increase - 0.99-0.95
      f := 1 - 0.01 * f32(u.current)
      g.player.weapon.sway.increase *= f
    },
    parent = 3,
    dir = .UpLeft,
  )
}

apply_upgrades :: proc() {
  for &u in g.progress.upgrades.items {
    if is_none(u.id) do continue
    if !upgrade_is_active(&u) do continue
    switch u.trigger {
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

upgrade_get_price :: proc(u: ^Upgrade) -> UpgradePrice {
  price: UpgradePrice
  for kind in ResourceKind {
    if u.price[kind] > 0 {
      price[kind] = u.price[kind] + u.price_step * u.current
    }
  }
  return price
}

upgrade_can_afford :: proc(u: ^Upgrade) -> bool {
  have := &g.progress.inventory.resources
  price := upgrade_get_price(u)
  for kind in ResourceKind {
    if have[kind] < u64(price[kind]) {
      return false
    }
  }
  return true
}

upgrade_purchase :: proc(u: ^Upgrade) {
  have := &g.progress.inventory.resources
  price := upgrade_get_price(u)
  for kind in ResourceKind {
    have[kind] -= u64(price[kind])
  }
  u.current += 1
}
