package render

import rl "vendor:raylib"

Icon :: struct {
  kind:     IconKind,
  position: Vec2,
  size:     f32,
  color:    rl.Color,
}

IconKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
  DebugFps,
}

@(private = "file")
icon_queue: Pool(Icon, 1024)

icons_begin :: proc() {
  clear_pool(&icon_queue)
}

icons_end :: proc() {
  texture: rl.Texture = textures.icons

  for icon in every(&icon_queue) {
    source := Rect{0, 0, 32, 32}
    size := Vec2{16, 16} * icon.size
    switch icon.kind {
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
    case .DebugFps:
      rl.DrawFPS(i32(icon.position.x), i32(icon.position.y))
      continue
    }
    rl.DrawTexturePro(
      texture,
      source,
      Rect{icon.position.x, icon.position.y, size.x, size.y},
      size / 2,
      0,
      icon.color,
    )
  }
}

// TODO:
// rl.DrawBillboardPro(
// 	ctx.camera.camera3d,
// 	ctx.assets.bullet_texture,
// 	rect,
// 	position + icon.offset + forward * 0.5,
// 	ctx.camera.up,
// 	icon.size,
// 	rl.Vector2{icon.size.x / 2, icon.size.y / 2},
// 	icon.angle,
// 	rl.Color{255, 255, 255, u8(icon.alpha * 255)},
// )

add_icon_vec2 :: proc(kind: IconKind, position: Vec2, color: rl.Color = rl.WHITE) {
  push(&icon_queue, Icon{kind, position, 1, color})
}
add_icon_vec2_size :: proc(
  kind: IconKind,
  position: Vec2,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  push(&icon_queue, Icon{kind, position, size, color})
}
add_icon_vec3 :: proc(kind: IconKind, position: Vec3, color: rl.Color = rl.WHITE) {
  if is_on_screen(position) {
    push(&icon_queue, Icon{kind, get_screen_position(position), 1, color})
  }
}
add_icon_vec3_size :: proc(
  kind: IconKind,
  position: Vec3,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  if is_on_screen(position) {
    push(&icon_queue, Icon{kind, get_screen_position(position), size, color})
  }
}
icon :: proc {
  add_icon_vec2,
  add_icon_vec2_size,
  add_icon_vec3,
  add_icon_vec3_size,
}

