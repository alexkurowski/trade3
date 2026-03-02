#+private
package render

import rl "vendor:raylib"

shaders: struct {
  base:     rl.Shader,
  lighting: rl.Shader,
}
models: struct {
  test: rl.Model,
}
textures: struct {
  sprites: rl.Texture,
}

load_shaders :: proc() {
  {
    shaders.base = rl.LoadShader(
      "assets/shaders/gl330/base_vertex.glsl",
      "assets/shaders/gl330/base_fragment.glsl",
    )
  }
  {
    shaders.lighting = rl.LoadShader(
      "assets/shaders/gl330/lighting_vertex.glsl",
      "assets/shaders/gl330/lighting_fragment.glsl",
    )
    ambientColor := [4]f32{0.15, 0.4, 0.8, 1.0}
    rl.SetShaderValue(
      shaders.lighting,
      rl.GetShaderLocation(shaders.lighting, "ambient"),
      &ambientColor,
      .VEC4,
    )
  }
}

unload_shaders :: proc() {
  rl.UnloadShader(shaders.base)
  rl.UnloadShader(shaders.lighting)
}

load_models :: proc() {
  models.test = load_and_set_shader("assets/models/test.gltf", &shaders.lighting)
}

unload_models :: proc() {
  rl.UnloadModel(models.test)
}

@(private = "file")
load_and_set_shader :: proc(path: cstring, shader: ^rl.Shader) -> rl.Model {
  model := rl.LoadModel(path)
  for i := i32(0); i < model.materialCount; i += 1 {
    model.materials[i].shader = shader^
  }
  return model
}

load_textures :: proc() {
  textures.sprites = rl.LoadTexture("assets/textures/icons.png")
}

unload_textures :: proc() {
  rl.UnloadTexture(textures.sprites)
}
