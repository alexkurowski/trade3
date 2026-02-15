#+private
package game

import "deps:box"
import rl "vendor:raylib"

SpriteKind :: enum {
  Star,
  Station,
  Planet,
  City,
  Ship,
}
Sprite :: struct {
  kind:     SpriteKind,
  position: Vec2,
}

@(private = "file")
sprite_queue: box.Pool(Sprite, 256)

clear_sprites :: proc() {
  box.clear(&sprite_queue)
}

add_sprite :: proc {
  add_sprite_vec2,
  add_sprite_vec3,
}
add_sprite_vec2 :: proc(kind: SpriteKind, position: Vec2) {
  box.append(&sprite_queue, Sprite{kind, position})
}
add_sprite_vec3 :: proc(kind: SpriteKind, position: Vec3) {
  if is_on_screen(position) {
    box.append(&sprite_queue, Sprite{kind, to_screen_position(position)})
  }
}

draw_sprites :: proc() {
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
      rl.WHITE,
    )
  }
}

draw_plane_line :: proc(position: Vec3, zero_y: f32 = 0) {
  p1 := position
  if p1.y > zero_y + 0.3 {
    p1.y -= 0.2
  } else if p1.y < zero_y - 0.3 {
    p1.y += 0.2
  } else {
    return
  }
  p2 := Vec3{p1.x, zero_y, p1.z}
  rl.DrawLine3D(p1, p2, rl.WHITE)
}
