package render

import "deps:box"
import rl "vendor:raylib"

Shape :: struct {
  kind:       ShapeKind,
  position_a: Vec3,
  position_b: Vec3,
  color:      rl.Color,
}

ShapeKind :: enum {
  DebugGrid,
  Line,
  CircleY,
  SphereWires,
}

@(private = "file")
shape_queue: box.Pool(Shape, 256)

shapes_begin :: proc() {
  box.clear(&shape_queue)
}

shapes_end :: proc() {
  for shape in box.every(&shape_queue) {
    switch shape.kind {
    case .DebugGrid:
      rl.DrawGrid(i32(shape.position_a.x), shape.position_a.y)
    case .Line:
      rl.DrawLine3D(shape.position_a, shape.position_b, shape.color)
    case .CircleY:
      rl.DrawCircle3D(shape.position_a, shape.position_b.x, Vec3{1, 0, 0}, 90, shape.color)
    case .SphereWires:
      rl.DrawSphereWires(shape.position_a, shape.position_b.x, 8, 10, rl.GREEN)
    }
  }

}

add_shape_1 :: proc(kind: ShapeKind, a: Vec3, color: rl.Color = rl.WHITE) {
  box.append(&shape_queue, Shape{kind, a, Vec3(0), color})
}
add_shape_2f :: proc(kind: ShapeKind, a: Vec3, b: f32, color: rl.Color = rl.WHITE) {
  box.append(&shape_queue, Shape{kind, a, Vec3(b), color})
}
add_shape_2 :: proc(kind: ShapeKind, a, b: Vec3, color: rl.Color = rl.WHITE) {
  box.append(&shape_queue, Shape{kind, a, b, color})
}
shape :: proc {
  add_shape_1,
  add_shape_2f,
  add_shape_2,
}
