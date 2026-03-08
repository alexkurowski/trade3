package render

import "deps:box"
import rl "vendor:raylib"

Sprite :: struct {
  kind:     SpriteKind,
  position: Vec3,
  size:     f32,
  flip:     bool,
  color:    rl.Color,
}

SpriteKind :: enum {
  None,
  Character,
}

@(private = "file")
sprite_queue: box.Pool(Sprite, 1024)

sprites_begin :: proc() {
  box.clear(&sprite_queue)
}

sprites_end :: proc() {
  rl.BeginShaderMode(shaders.sprites)
  defer rl.EndShaderMode()

  for sprite in box.every(&sprite_queue) {
    sprite_size :: 16
    source := Rect{0, 0, sprite_size, sprite_size}
    size := Vec2{1, 1} * sprite.size
    origin := Vec2{size.x / 2, 0}
    switch sprite.kind {
    case .None:
      continue
    case .Character:
      source.x = 1 * sprite_size
      source.y = 0 * sprite_size
    }
    if sprite.flip {
      source.width *= -1
      source.x += sprite_size
    }
    rl.DrawBillboardPro(
      camera.c3d,
      textures.sprites,
      source,
      sprite.position,
      camera.up,
      size,
      origin,
      0,
      sprite.color,
    )
  }
}

add_sprite_vec3 :: proc(
  kind: SpriteKind,
  position: Vec3,
  size: f32 = 1,
  flip: bool = false,
  color: rl.Color = rl.WHITE,
) {
  box.append(&sprite_queue, Sprite{kind, position, size, flip, color})
}
sprite :: proc {
  add_sprite_vec3,
}
