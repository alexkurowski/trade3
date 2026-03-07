#+private
package render

import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_SPEED :: 2
CAMERA_OFFSET :: Vec3{10, 10, 10}

camera: struct {
  c3d:    rl.Camera3D,
  m3d:    rl.Matrix,
  offset: Vec3,
  target: Vec3,
  fovy:   f32,
}

camera_init :: proc() {
  camera.offset = CAMERA_OFFSET
  camera.target = Vec3(0)
  camera.fovy = 15
  camera.c3d.projection = .ORTHOGRAPHIC
  camera.c3d.target = Vec3(0)
  camera.c3d.position = camera.offset
  camera.c3d.fovy = camera.fovy
  camera.c3d.up = Vec3{0, 1, 0}
}

camera_step :: proc(dt: f32) {
  // Lerp camera positions
  camera.c3d.target = linalg.lerp(camera.c3d.target, camera.target, CAMERA_SPEED * dt)
  camera.c3d.position = linalg.lerp(
    camera.c3d.position,
    camera.c3d.target + camera.offset,
    CAMERA_SPEED * 5 * dt,
  )
  camera.c3d.fovy = linalg.lerp(camera.c3d.fovy, camera.fovy, CAMERA_SPEED * dt)
  // Recalculate camera
  camera.m3d = rl.GetCameraMatrix(camera.c3d)
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

