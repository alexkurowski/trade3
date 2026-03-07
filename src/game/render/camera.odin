#+private
package render

import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_SPEED :: 4
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
    camera.target + camera.offset,
    CAMERA_SPEED * dt,
  )
  camera.c3d.fovy = linalg.lerp(camera.c3d.fovy, camera.fovy, CAMERA_SPEED * dt)
  // Recalculate camera
  camera.m3d = rl.GetCameraMatrix(camera.c3d)
}

