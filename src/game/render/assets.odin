#+private
package render

import rl "vendor:raylib"

shaders: struct {
  lighting: rl.Shader,
}
models: struct {
  test: rl.Model,
}

load_shaders :: proc() {
  {
    shaders.lighting = rl.LoadShader(
      "assets/shaders/gl330/lighting_vertex.glsl",
      "assets/shaders/lighting_fragment.glsl",
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
