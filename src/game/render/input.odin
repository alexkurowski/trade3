#+private
package render

import rl "vendor:raylib"

mouse_delta: Vec2
mouse_screen_position: Vec2
mouse_world_position: Vec3

@(private = "file")
q := [4]Vec3{Vec3{-100, 0, -100}, Vec3{100, 0, -100}, Vec3{100, 0, 100}, Vec3{-100, 0, 100}}

input_step :: proc() {
  mouse_delta = rl.GetMouseDelta()
  mouse_screen_position = rl.GetMousePosition()
  mouse_world_position = get_world_position_from_screen(mouse_screen_position)
}

get_world_position_from_screen :: proc(position: Vec2) -> Vec3 {
  ray := rl.GetScreenToWorldRay(position, camera.c3d)
  collision := rl.GetRayCollisionQuad(ray, q[0], q[1], q[2], q[3])
  return collision.point
}

