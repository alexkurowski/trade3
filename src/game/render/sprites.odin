package render

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
  EnemyA,
  EnemyB,
}

@(private = "file")
sprite_queue: Pool(Sprite, 1024)

sprites_begin :: proc() {
  clear_pool(&sprite_queue)
}

sprites_end :: proc() {
  rl.BeginShaderMode(shaders.sprites)
  defer rl.EndShaderMode()

  for sprite in every(&sprite_queue) {
    sprite_size :: 16
    x, y := f32(0), f32(0)
    switch sprite.kind {
    case .None:
      continue
    case .Character:
      x = 0
      y = 0
    case .EnemyA:
      x = 0
      y = 1
    case .EnemyB:
      x = 0
      y = 2
    }
    source := Rect{x * sprite_size, y * sprite_size, sprite_size, sprite_size}
    size := Vec2{1, 1} * sprite.size
    origin := Vec2{size.x / 2, 0}
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
  push(&sprite_queue, Sprite{kind, position, size, flip, color})
}
sprite :: proc {
  add_sprite_vec3,
}

