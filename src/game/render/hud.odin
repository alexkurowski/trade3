package render

import rl "vendor:raylib"

Hud :: struct {
  kind:     HudKind,
  position: Vec2,
  size_a:   Vec2,
  size_b:   Vec2,
  color:    rl.Color,
}

HudKind :: enum {
  ReloadCounter,
  DebugFps,
  Circle,
}

@(private = "file")
elements_queue: Pool(Hud, 1024)

hud_begin :: proc() {
  clear_pool(&elements_queue)
}

hud_end :: proc() {
  texture: rl.Texture = textures.icons

  for el in every(&elements_queue) {
    source := Rect{0, 0, 32, 32}
    size_a := Vec2{16, 16} * el.size_a
    switch el.kind {
    case .ReloadCounter:
      if el.size_a.x > 0 {
        width :: 64
        height :: 12
        padding :: 3
        x := i32(el.position.x - width / 2)
        y := i32(el.position.y)
        // Outline
        rl.DrawRectangleLines(x, y, width, height, rl.WHITE)
        // QTE window
        rl.DrawRectangle(
          x + padding + i32((width - padding * 2) * el.size_b.x),
          y + padding,
          i32((width - padding * 2) * el.size_b.y),
          height - padding * 2,
          rl.LIGHTGRAY,
        )
        // Progress bar
        rl.DrawRectangle(
          x + padding,
          y + padding,
          i32((width - padding * 2) * el.size_a.x),
          height - padding * 2,
          rl.WHITE,
        )
      }
    case .DebugFps:
      rl.DrawFPS(i32(el.position.x), i32(el.position.y))
    case .Circle:
      rl.DrawCircleLinesV(el.position, el.size_a.x, el.color)
    }
  }
}

add_hud :: proc(kind: HudKind, position: Vec2, color: rl.Color = rl.WHITE) {
  push(&elements_queue, Hud{kind, position, 1, 0, color})
}
add_hud_size1 :: proc(kind: HudKind, position: Vec2, size_a: f32 = 1, color: rl.Color = rl.WHITE) {
  push(&elements_queue, Hud{kind, position, size_a, 0, color})
}
add_hud_size2 :: proc(
  kind: HudKind,
  position: Vec2,
  size_a: f32 = 1,
  size_b: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  push(&elements_queue, Hud{kind, position, size_a, size_b, color})
}
add_hud_size3 :: proc(
  kind: HudKind,
  position: Vec2,
  size_a: f32,
  size_b_x: f32,
  size_b_y: f32,
  color: rl.Color = rl.WHITE,
) {
  push(&elements_queue, Hud{kind, position, size_a, Vec2{size_b_x, size_b_y}, color})
}
hud :: proc {
  add_hud,
  add_hud_size1,
  add_hud_size2,
  add_hud_size3,
}

