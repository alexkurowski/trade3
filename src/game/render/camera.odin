#+private
package render

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_SPEED :: 4
CAMERA_PITCH :: 90 - 35.264
CAMERA_YAW :: 90
CAMERA_DISTANCE :: 7
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
  camera.offset = calculate_camera_offset(CAMERA_PITCH, CAMERA_YAW, CAMERA_DISTANCE)
  camera.target = Vec3(0)
  camera.fovy = CAMERA_FOV
  camera.c3d.projection = .PERSPECTIVE // .ORTHOGRAPHIC
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

calculate_camera_offset :: proc(pitch, yaw, distance: f32) -> Vec3 {
  pitch_rad := pitch * math.RAD_PER_DEG
  yaw_rad := yaw * math.RAD_PER_DEG
  vec := Vec3 {
    CAMERA_DISTANCE * math.cos(pitch_rad) * math.cos(yaw_rad),
    CAMERA_DISTANCE * math.sin(pitch_rad),
    CAMERA_DISTANCE * math.cos(pitch_rad) * math.sin(yaw_rad),
  }
  return vec * distance
}
