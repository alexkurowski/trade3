#+private
package physics

import b2 "vendor:box2d"
import rl "vendor:raylib"

Vec2 :: [2]f32
Vec3 :: [3]f32

physics_world_debug: b2.DebugDraw

init_debug_draw :: proc() {
  physics_world_debug = b2.DefaultDebugDraw()
  physics_world_debug.drawShapes = true
  physics_world_debug.DrawSolidCircleFcn = proc "c" (
    transform: b2.Transform,
    radius: f32,
    color: b2.HexColor,
    ctx: rawptr,
  ) {
    rl.DrawCircle3D(Vec3{transform.p.x, 0, transform.p.y}, radius, Vec3{1, 0, 0}, 90, rl.RED)
  }
  physics_world_debug.DrawPolygonFcn = proc "c" (
    vertices: [^]b2.Vec2,
    vertex_count: i32,
    color: b2.HexColor,
    ctx: rawptr,
  ) {
    for i: i32 = 0; i < vertex_count; i += 1 {
      v1 := vertices[i]
      v2 := vertices[(i + 1) % vertex_count]
      rl.DrawLine3D(Vec3{v1.x, 0, v1.y}, Vec3{v2.x, 0, v2.y}, rl.GREEN)
    }
  }
  physics_world_debug.DrawSolidPolygonFcn = proc "c" (
    transform: b2.Transform,
    vertices: [^]b2.Vec2,
    vertex_count: i32,
    radius: f32,
    color: b2.HexColor,
    ctx: rawptr,
  ) {
    for i: i32 = 0; i < vertex_count; i += 1 {
      v1 := b2.TransformPoint(transform, vertices[i])
      v2 := b2.TransformPoint(transform, vertices[(i + 1) % vertex_count])
      rl.DrawCircle3D(Vec3{v1.x, 0, v1.y}, radius, Vec3{1, 0, 0}, 90, rl.RED)
      rl.DrawLine3D(Vec3{v1.x, 0, v1.y}, Vec3{v2.x, 0, v2.y}, rl.RED)
    }
  }
}
