#+private
package game

import "deps:box"
import rl "vendor:raylib"

Sprite :: struct {
  kind:     SpriteKind,
  position: Vec2,
  color:    rl.Color,
}

SpriteKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
}

@(private = "file")
sprite_queue: box.Pool(Sprite, 256)

sprites_begin :: proc() {
  box.clear(&sprite_queue)
}

sprites_end :: proc() {
  for sprite in box.every(&sprite_queue) {
    source := Rect{0, 0, 32, 32}
    size := Vec2{16, 16}
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
    }
    rl.DrawTexturePro(
      assets.textures.icons,
      source,
      Rect{sprite.position.x, sprite.position.y, size.x, size.y},
      size / 2,
      0,
      sprite.color,
    )
  }
}

add_sprite_vec2 :: proc(kind: SpriteKind, position: Vec2, color: rl.Color = rl.WHITE) {
  box.append(&sprite_queue, Sprite{kind, position, color})
}
add_sprite_vec3 :: proc(kind: SpriteKind, position: Vec3, color: rl.Color = rl.WHITE) {
  if is_on_screen(position) {
    box.append(&sprite_queue, Sprite{kind, to_screen_position(position), color})
  }
}
draw_sprite :: proc {
  add_sprite_vec2,
  add_sprite_vec3,
}
