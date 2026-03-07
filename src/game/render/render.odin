package render

import rl "vendor:raylib"

@(private)
dt: f32

load :: proc() {
  load_shaders()
  load_textures()
  load_models()
}

unload :: proc() {
  unload_models()
  unload_textures()
  unload_shaders()
}

begin :: proc(delta_time: f32) {
  dt = delta_time
  camera_step(dt)
  shapes_begin()
  models_begin()
  sprites_begin()
}

begin_3d :: proc() {
  rl.BeginMode3D(camera.c3d)
}

end_3d :: proc() {
  rl.EndMode3D()
}

begin_2d :: proc() {
  // rl.BeginShaderMode(assets.shaders.base)
}

end_2d :: proc() {
  // rl.EndShaderMode()
  // rl.EndMode2D()
}
