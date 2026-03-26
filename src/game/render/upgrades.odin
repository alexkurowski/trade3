package render

import rl "vendor:raylib"

Upgrade :: struct {
  kind:     UpgradeKind,
  position: Vec2,
  size:     f32,
  state:    UpgradeState,
  current:  i32,
  max:      i32,
}

UpgradeKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
}

UpgradeState :: enum {
  Normal,
  Hover,
  Active,
  Complete,
  Known,
}

@(private = "file")
upgrade_queue: Pool(Upgrade, 1024)

upgrades_begin :: proc() {
  clear_pool(&upgrade_queue)
}

upgrades_end :: proc() {
  texture: rl.Texture = textures.icons

  for upgrade in every(&upgrade_queue) {
    source := Rect{0, 0, 32, 32}
    size := Vec2{24, 24} * upgrade.size
    switch upgrade.kind {
    case .Star:
      source.x = 32
      source.y = 32
    case .Station:
      source.x = 64
    case .Planet:
      source.x = 32
    case .City:
      source.x = 96
    case .Ship:
      source.x = 128
      source.y = 32
    }
    rect := Rect{upgrade.position.x, upgrade.position.y, size.x, size.y}
    color: rl.Color = rl.WHITE

    // Background
    if upgrade.state == .Hover {
      color = rl.BLACK
      rl.DrawRectangleRec(rect, rl.WHITE)
    } else if upgrade.state == .Normal {
      rl.DrawRectangleLinesEx(rect, 2, rl.WHITE)
    } else if upgrade.state == .Complete {
      color = rl.BLACK
      rl.DrawRectangleRec(rect, rl.WHITE)
    } else if upgrade.state == .Known {
      color = rl.DARKGRAY
    }
    // Icon
    rl.DrawTexturePro(texture, source, rect, 0, 0, color)
    // Purchased pips
    if upgrade.current > 0 && upgrade.max > 0 {
      rect.y += rect.height
      rect.width /= f32(upgrade.max)
      rect.height = 4
      for i := i32(0); i < upgrade.max; i += 1 {
        if i < upgrade.current {
          rl.DrawRectangleRec(rect, rl.WHITE)
        } else {
          rl.DrawRectangleLinesEx(rect, 1, rl.WHITE)
        }
        rect.x += rect.width
      }
    }
  }
}

upgrade :: proc(
  kind: UpgradeKind,
  position: Vec2,
  size: f32 = 1,
  state: UpgradeState = .Normal,
  current: i32 = 0,
  max: i32 = 0,
) {
  push(&upgrade_queue, Upgrade{kind, position, size, state, current, max})
}

