package physics

import "core:math"
import b2 "vendor:box2d"

WID :: b2.WorldId
BID :: b2.BodyId
SID :: b2.ShapeId

Body :: struct {
  bid:  BID,
  sid:  SID,
  size: f32,
}

BodyShape :: enum {
  Box,
  RoundedBox,
  Circle,
}

create_body :: proc() -> Body {
  body_def := b2.DefaultBodyDef()
  body_def.type = .dynamicBody
  body_def.linearDamping = 6
  body_def.angularDamping = 6
  return Body{bid = b2.CreateBody(world, body_def)}
}

destroy_body :: proc(body: Body) {
  b2.DestroyBody(body.bid)
}

set_body_shape :: proc(
  body: ^Body,
  shape: BodyShape,
  size_a: f32 = 1,
  size_b: f32 = 1,
  mass: f32 = 4,
  is_sensor: bool = false,
) {
  // NOTE: Perhaps Body don't need SID (shape id)

  if size_a <= 0 || size_b <= 0 do panic("Size must be greater than zero")

  half_a := size_a / 2
  half_b := size_b / 2

  body.size = half_a

  shape_def := b2.DefaultShapeDef()
  shape_def.material.friction = 10
  shape_def.material.restitution = 0.1
  shape_def.material.rollingResistance = 0.2
  shape_def.material.tangentSpeed = 0
  shape_def.isSensor = is_sensor

  area: f32
  switch shape {
  case .Box:
    polygon := b2.MakeBox(half_a, half_b)
    body.sid = b2.CreatePolygonShape(body.bid, shape_def, polygon)
    area = size_a * size_b
  case .RoundedBox:
    polygon := b2.MakeRoundedBox(half_a, half_b, 0.8)
    body.sid = b2.CreatePolygonShape(body.bid, shape_def, polygon)
    area = size_a * size_b
  case .Circle:
    circle := b2.Circle {
      radius = half_a,
    }
    body.sid = b2.CreateCircleShape(body.bid, shape_def, circle)
    area = math.PI * (half_a * half_a)
  }

  density := mass / area
  b2.Shape_SetDensity(body.sid, density, true)
}

