package render

import rl "vendor:raylib"

Upgrade :: struct {
  kind:     UpgradeKind,
  position: Vec2,
  size:     f32,
  color:    rl.Color,
  state:    UpgradeState,
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
    size := Vec2{16, 16} * upgrade.size
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
    rl.DrawTexturePro(
      texture,
      source,
      Rect{upgrade.position.x, upgrade.position.y, size.x, size.y},
      size / 2,
      0,
      upgrade.color,
    )
  }
}

add_upgrade_vec2 :: proc(kind: UpgradeKind, position: Vec2, color: rl.Color = rl.WHITE) {
  push(&upgrade_queue, Upgrade{kind, position, 1, color})
}
add_upgrade_vec2_size :: proc(
  kind: UpgradeKind,
  position: Vec2,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  push(&upgrade_queue, Upgrade{kind, position, size, color})
}
upgrade :: proc {
  add_upgrade_vec2,
  add_upgrade_vec2_size,
}

