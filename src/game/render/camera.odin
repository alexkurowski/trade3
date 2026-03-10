#+private
package render

import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_SPEED :: 4
CAMERA_OFFSET :: Vec3{2.5, 10, 4}
CAMERA_FOV :: 24

camera: struct {
  c3d:    rl.Camera3D,
  m3d:    rl.Matrix,
  speed:  f32,
  offset: Vec3,
  target: Vec3,
  up:     Vec3,
  fovy:   f32,
}

camera_init :: proc() {
  camera.speed = CAMERA_SPEED
  camera.offset = CAMERA_OFFSET
  camera.target = Vec3(0)
  camera.fovy = CAMERA_FOV
  camera.c3d.projection = .ORTHOGRAPHIC
  camera.c3d.target = Vec3(0)
  camera.c3d.position = camera.offset
  camera.c3d.fovy = CAMERA_FOV
  camera.c3d.up = Vec3{0, 1, 0}
}

camera_step :: proc(dt: f32) {
  // Lerp camera positions
  camera.c3d.target = linalg.lerp(camera.c3d.target, camera.target, camera.speed * dt)
  camera.c3d.position = linalg.lerp(
    camera.c3d.position,
    camera.target + camera.offset,
    camera.speed * 1.5 * dt,
  )
  camera.c3d.fovy = linalg.lerp(camera.c3d.fovy, camera.fovy, camera.speed * dt)
  // Recalculate camera
  camera.m3d = rl.GetCameraMatrix(camera.c3d)
  // Recalculate camera up
  forward := linalg.normalize(camera.c3d.target - camera.c3d.position)
  right := linalg.normalize(linalg.cross(camera.c3d.up, forward))
  camera.up = linalg.normalize(linalg.cross(forward, right))
}
