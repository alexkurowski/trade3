#+private
package game

import rl "vendor:raylib"

@(private = "file")
camera_matrix: rl.Matrix
@(private = "file")
camera_3d: rl.Camera

render_begin_3d :: proc(camera: rl.Camera) {
  camera_3d = camera
  camera_matrix = rl.GetCameraMatrix(camera)
  rl.BeginMode3D(camera)
  rl.BeginShaderMode(assets.shaders.base)
}

render_end_3d :: proc() {
  rl.EndShaderMode()
  rl.EndMode3D()
}

render_begin_2d :: proc() {
  rl.BeginShaderMode(assets.shaders.base)
}

render_end_2d :: proc() {
  rl.EndShaderMode()
  rl.EndMode2D()
}


is_on_screen :: #force_inline proc(position: Vec3) -> bool {
  t := rl.Vector3Transform(position, camera_matrix)
  return t.z < -0.1
}

get_screen_position :: #force_inline proc(position: Vec3) -> Vec2 {
  return rl.GetWorldToScreen(position, camera_3d)
}

to_screen_position :: #force_inline proc(position: Vec3) -> (Vec2, bool) #optional_ok {
  return get_screen_position(position), is_on_screen(position)
}
