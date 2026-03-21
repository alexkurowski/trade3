package render

import "core:math/linalg"
import rl "vendor:raylib"

@(private)
dt: f32

load :: proc() {
  load_shaders()
  load_textures()
  load_models()

  camera_init()
}

unload :: proc() {
  unload_models()
  unload_textures()
  unload_shaders()
}

begin :: proc(delta_time: f32) {
  dt = delta_time
  camera_step(dt)
  input_step()
  shapes_begin()
  models_begin()
  sprites_begin()
  icons_begin()
}

begin_3d :: proc() {
  rl.BeginMode3D(camera.c3d)
}

draw_3d :: proc() {
  shapes_end()
  models_end()
  sprites_end()
}

end_3d :: proc() {
  rl.EndMode3D()
}

begin_2d :: proc() {
  // rl.BeginShaderMode(assets.shaders.base)
}

draw_2d :: proc() {
  icons_end()
}

end_2d :: proc() {
  // rl.EndShaderMode()
  // rl.EndMode2D()
}

//
// Camera interactions
//
move_camera_to :: proc(position: Vec3) {
  camera.target = position
}

//
// 3d to 2d helpers
//
is_on_screen :: #force_inline proc(position: Vec3) -> bool {
  t := rl.Vector3Transform(position, camera.m3d)
  return t.z < -0.1
}

get_screen_position :: #force_inline proc(position: Vec3) -> Vec2 {
  return rl.GetWorldToScreen(position, camera.c3d)
}

to_screen_position :: proc(position: Vec3) -> (Vec2, bool) {
  return get_screen_position(position), is_on_screen(position)
}

get_world_position :: proc(position: Vec2) -> Vec3 {
  return get_world_position_from_screen(position)
}

to_camera_relative :: proc(v: Vec2) -> Vec2 {
  direction := linalg.normalize(camera.c3d.target - camera.c3d.position)
  forward := Vec2{direction.x, direction.z}
  right := Vec2{-direction.z, direction.x}
  return Vec2{linalg.dot(v, right), linalg.dot(v, forward)}
}

get_mouse_world_position :: proc() -> Vec3 {
  return mouse_world_position
}

get_mouse_screen_position :: proc() -> Vec2 {
  return mouse_screen_position
}

