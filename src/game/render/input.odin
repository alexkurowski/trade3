#+private
package render

import rl "vendor:raylib"

mouse_world_position: Vec3

@(private = "file")
q := [4]Vec3{Vec3{-100, 0, -100}, Vec3{100, 0, -100}, Vec3{100, 0, 100}, Vec3{-100, 0, 100}}

input_step :: proc() {
  ray := rl.GetScreenToWorldRay(rl.GetMousePosition(), camera.c3d)
  col := rl.GetRayCollisionQuad(ray, q[0], q[1], q[2], q[3])
  mouse_world_position = col.point
}

