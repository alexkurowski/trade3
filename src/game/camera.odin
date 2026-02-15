#+private
package game

import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

CAMERA_CLOSEST :: 5
CAMERA_FARTHEST :: 250
CAMERA_SPEED :: 4
CAMERA_MIN_PITCH :: -80
CAMERA_MAX_PITCH :: 80

Camera :: struct {
  c3d:            rl.Camera3D,
  m3d:            rl.Matrix,
  offset:         Vec3,
  target:         Vec3,
  forward:        Vec3,
  right:          Vec3,
  up:             Vec3,
  ground_forward: Vec3,
  ground_right:   Vec3,
  angle:          Vec2,
  distance:       f32,
}

new_camera :: proc() -> Camera {
  c: Camera
  c.target = Vec3(0)
  c.angle = Vec2{225, 45}
  c.distance = 100
  c.c3d.fovy = 20
  c.c3d.projection = .PERSPECTIVE
  c.c3d.target = Vec3(0)
  c.c3d.position = Vec3(10)
  c.c3d.up = Vec3{0, 1, 0}
  return c
}

camera_step :: proc() {
  c := &g.camera

  // Camera
  c.distance = math.clamp(c.distance, CAMERA_CLOSEST, CAMERA_FARTHEST)
  c.angle.y = math.clamp(c.angle.y, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)
  // Recalculate c offset
  a := c.angle
  c.offset.x = math.cos(a.y * DEG_TO_RAD) * math.sin(a.x * DEG_TO_RAD)
  c.offset.y = math.sin(a.y * DEG_TO_RAD)
  c.offset.z = math.cos(a.y * DEG_TO_RAD) * math.cos(a.x * DEG_TO_RAD)
  c.offset *= c.distance
  // Lerp camera
  c.c3d.target = linalg.lerp(c.c3d.target, c.target, CAMERA_SPEED * time.dt)
  c.c3d.position = linalg.lerp(c.c3d.position, c.c3d.target + c.offset, CAMERA_SPEED * time.dt * 5)
  // Recalculate matrix
  c.m3d = rl.GetCameraMatrix(c.c3d)
  // Recalculate camera directions
  forward := c.c3d.target - c.c3d.position
  c.forward = linalg.normalize(forward)
  c.right = linalg.normalize(linalg.cross(c.c3d.up, c.forward))
  c.up = linalg.normalize(linalg.cross(c.forward, c.right))
  forward.y = 0
  c.ground_forward = linalg.normalize(forward)
  c.ground_right = linalg.normalize(linalg.cross(c.c3d.up, forward))
}

camera_controls :: proc() {
  c := &g.camera

  {
    move: Vec3
    speed :: 20
    if rl.IsKeyDown(.A) do move.x = +speed
    if rl.IsKeyDown(.D) do move.x = -speed
    if rl.IsKeyDown(.Q) do move.y = -speed
    if rl.IsKeyDown(.E) do move.y = +speed
    if rl.IsKeyDown(.W) do move.z = +speed
    if rl.IsKeyDown(.S) do move.z = -speed
    move_by := c.ground_right * move.x + {0, move.y, 0} + c.ground_forward * move.z
    move_by *= time.dt
    c.target += move_by
  }
  {
    rotate: Vec2
    zoom: f32
    if rl.IsKeyDown(.LEFT_SHIFT) {
      zoom = -rl.GetMouseWheelMoveV().y
    } else {
      rotate = rl.GetMouseWheelMoveV() * 2.5
    }
    c.angle.x += rotate.x
    c.angle.y -= rotate.y
    c.distance += zoom
  }
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

to_screen_position :: #force_inline proc(position: Vec3) -> (Vec2, bool) #optional_ok {
  return get_screen_position(position), is_on_screen(position)
}
