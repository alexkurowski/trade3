package render

import "deps:box"
import rl "vendor:raylib"

Sprite :: struct {
  kind:     SpriteKind,
  position: Vec2,
  size:     f32,
  color:    rl.Color,
}

SpriteKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
  DebugFps,
}

@(private = "file")
sprite_queue: box.Pool(Sprite, 1024)

sprites_begin :: proc() {
  box.clear(&sprite_queue)
}

sprites_end :: proc(texture: rl.Texture) {
  for sprite in box.every(&sprite_queue) {
    source := Rect{0, 0, 32, 32}
    size := Vec2{16, 16} * sprite.size
    switch sprite.kind {
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
      rl.DrawFPS(i32(sprite.position.x), i32(sprite.position.y))
      continue
    }
    rl.DrawTexturePro(
      texture,
      source,
      Rect{sprite.position.x, sprite.position.y, size.x, size.y},
      size / 2,
      0,
      sprite.color,
    )
  }
}

add_sprite_vec2 :: proc(kind: SpriteKind, position: Vec2, color: rl.Color = rl.WHITE) {
  box.append(&sprite_queue, Sprite{kind, position, 1, color})
}
add_sprite_vec2_size :: proc(
  kind: SpriteKind,
  position: Vec2,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  box.append(&sprite_queue, Sprite{kind, position, size, color})
}
add_sprite_vec3 :: proc(kind: SpriteKind, position: Vec3, color: rl.Color = rl.WHITE) {
  if is_on_screen(position) {
    box.append(&sprite_queue, Sprite{kind, get_screen_position(position), 1, color})
  }
}
add_sprite_vec3_size :: proc(
  kind: SpriteKind,
  position: Vec3,
  size: f32 = 1,
  color: rl.Color = rl.WHITE,
) {
  if is_on_screen(position) {
    box.append(&sprite_queue, Sprite{kind, get_screen_position(position), size, color})
  }
}
sprite :: proc {
  add_sprite_vec2,
  add_sprite_vec2_size,
  add_sprite_vec3,
  add_sprite_vec3_size,
}
