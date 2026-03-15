#+private
package render

import rl "vendor:raylib"

mouse_screen_position: Vec2
mouse_world_position: Vec3

@(private = "file")
q := [4]Vec3{Vec3{-100, 0, -100}, Vec3{100, 0, -100}, Vec3{100, 0, 100}, Vec3{-100, 0, 100}}

input_step :: proc() {
  mouse_screen_position = rl.GetMousePosition()
  ray := rl.GetScreenToWorldRay(mouse_screen_position, camera.c3d)
  collision := rl.GetRayCollisionQuad(ray, q[0], q[1], q[2], q[3])
  mouse_world_position = collision.point
}

