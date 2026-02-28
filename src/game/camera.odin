#+private
package game

import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_SPEED :: 2
CAMERA_OFFSET :: Vec3{0, 0, 10}

Camera :: struct {
  c3d:    rl.Camera3D,
  m3d:    rl.Matrix,
  offset: Vec3,
  target: Vec3,
  fovy:   f32,
}

camera_init :: proc() {
  g.camera.target = Vec3(0)
  g.camera.fovy = 30
  g.camera.c3d.fovy = g.camera.fovy
  g.camera.c3d.projection = .ORTHOGRAPHIC
  g.camera.c3d.target = Vec3(0)
  g.camera.c3d.position = CAMERA_OFFSET
  g.camera.c3d.up = Vec3{0, 1, 0}
}

camera_step :: proc() {
  // Lerp camera positions
  g.camera.c3d.target = linalg.lerp(g.camera.c3d.target, g.camera.target, CAMERA_SPEED * time.dt)
  g.camera.c3d.position = linalg.lerp(
    g.camera.c3d.position,
    g.camera.c3d.target + CAMERA_OFFSET,
    CAMERA_SPEED * 5 * time.dt,
  )
  g.camera.c3d.fovy = linalg.lerp(g.camera.c3d.fovy, g.camera.fovy, CAMERA_SPEED * time.dt)
  // Recalculate camera
  g.camera.m3d = rl.GetCameraMatrix(g.camera.c3d)
}


//
// 3d to 2d helpers
//
is_on_screen :: #force_inline proc(position: Vec3) -> bool {
  t := rl.Vector3Transform(position, g.camera.m3d)
  return t.z < -0.1
}

get_screen_position :: #force_inline proc(position: Vec3) -> Vec2 {
  return rl.GetWorldToScreen(position, g.camera.c3d)
}

to_screen_position :: proc(position: Vec3) -> (Vec2, bool) {
  return get_screen_position(position), is_on_screen(position)
}
