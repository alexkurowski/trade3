package render

import rl "vendor:raylib"

@(private = "file")
camera3d: rl.Camera
@(private = "file")
camera_matrix: rl.Matrix

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

begin_3d :: proc(camera: rl.Camera) {
  camera3d = camera
  camera_matrix = rl.GetCameraMatrix(camera)
  rl.BeginMode3D(camera)
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

is_on_screen :: #force_inline proc(position: Vec3) -> bool {
  t := rl.Vector3Transform(position, camera_matrix)
  return t.z < -0.1
}

get_screen_position :: #force_inline proc(position: Vec3) -> Vec2 {
  return rl.GetWorldToScreen(position, camera3d)
}
