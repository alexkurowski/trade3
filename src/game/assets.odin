#+private
package game

import rl "vendor:raylib"

assets: struct {
  fonts:    struct {
    regular16: rl.Font,
    regular24: rl.Font,
  },
  textures: struct {
    sprites: rl.Texture,
    icons:   rl.Texture,
  },
  shaders:  struct {
    base: rl.Shader,
  },
}

assets_load :: proc() {
  assets.fonts.regular16 = rl.LoadFontEx("assets/fonts/Outfit-Regular.ttf", 32, nil, 0)
  assets.fonts.regular24 = rl.LoadFontEx("assets/fonts/Outfit-Regular.ttf", 48, nil, 0)

  assets.textures.sprites = rl.LoadTexture("assets/textures/sprites.png")
  assets.textures.icons = rl.LoadTexture("assets/textures/icons.png")

  assets.shaders.base = rl.LoadShader(
    "assets/shaders/gl330/base_vertex.glsl",
    "assets/shaders/gl330/base_fragment.glsl",
  )
}

assets_unload :: proc() {
  rl.UnloadFont(assets.fonts.regular16)
  rl.UnloadFont(assets.fonts.regular24)
  rl.UnloadTexture(assets.textures.sprites)
  rl.UnloadTexture(assets.textures.icons)
  rl.UnloadShader(assets.shaders.base)
}
