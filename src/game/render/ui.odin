package render

import rl "vendor:raylib"

UiElement :: struct {
  kind:     UiElementKind,
  position: Vec2,
  size:     Vec2,
  size2:    Vec2,
  color:    rl.Color,
}

UiElementKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
  ReloadCounter,
  DebugFps,
  Circle,
}

@(private = "file")
elements_queue: Pool(UiElement, 1024)

ui_begin :: proc() {
  clear_pool(&elements_queue)
}

ui_end :: proc() {
  texture: rl.Texture = textures.icons

  for el in every(&elements_queue) {
    source := Rect{0, 0, 32, 32}
    size := Vec2{16, 16} * el.size
    switch el.kind {
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
    case .ReloadCounter:
      if el.size.x > 0 {
        width :: 64
        height :: 12
        padding :: 3
        x := i32(el.position.x - width / 2)
        y := i32(el.position.y)
        // Outline
        rl.DrawRectangleLines(x, y, width, height, rl.WHITE)
        // QTE window
        rl.DrawRectangle(
          x + padding + i32((width - padding * 2) * el.size2.x),
          y + padding,
          i32((width - padding * 2) * el.size2.y),
          height - padding * 2,
          rl.LIGHTGRAY,
        )
        // Progress bar
        rl.DrawRectangle(
          x + padding,
          y + padding,
          i32((width - padding * 2) * el.size.x),
          height - padding * 2,
          rl.WHITE,
        )
      }
      continue
    case .DebugFps:
      rl.DrawFPS(i32(el.position.x), i32(el.position.y))
      continue
    case .Circle:
      rl.DrawCircleLinesV(el.position, el.size.x, el.color)
      continue
    }
    rl.DrawTexturePro(
      texture,
      source,
      Rect{el.position.x, el.position.y, size.x, size.y},
      size / 2,
      0,
      el.color,
    )
  }
}

// TODO:
// rl.DrawBillboardPro(
// 	ctx.camera.camera3d,
// 	ctx.assets.bullet_texture,
// 	rect,
// 	position + ui.offset + forward * 0.5,
// 	ctx.camera.up,
// 	ui.size,
// 	rl.Vector2{ui.size.x / 2, ui.size.y / 2},
// 	ui.angle,
// 	rl.Color{255, 255, 255, u8(ui.alpha * 255)},
// )

add_ui_vec2 :: proc(kind: UiElementKind, position: Vec2, color: rl.Color = rl.WHITE) {
  push(&elements_queue, UiElement{kind, position, 1, 0, color})
}
add_ui_vec2_size :: proc(
  kind: UiElementKind,
  position: Vec2,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  push(&elements_queue, UiElement{kind, position, size, 0, color})
}
add_ui_vec2_size2 :: proc(
  kind: UiElementKind,
  position: Vec2,
  size: f32 = 1,
  size2: Vec2 = 0,
  color: rl.Color = rl.WHITE,
) {
  push(&elements_queue, UiElement{kind, position, size, size2, color})
}
add_ui_vec3 :: proc(kind: UiElementKind, position: Vec3, color: rl.Color = rl.WHITE) {
  if is_on_screen(position) {
    push(&elements_queue, UiElement{kind, get_screen_position(position), 1, 0, color})
  }
}
add_ui_vec3_size :: proc(
  kind: UiElementKind,
  position: Vec3,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  if is_on_screen(position) {
    push(&elements_queue, UiElement{kind, get_screen_position(position), size, 0, color})
  }
}
ui :: proc {
  add_ui_vec2,
  add_ui_vec2_size,
  add_ui_vec2_size2,
  add_ui_vec3,
  add_ui_vec3_size,
}

