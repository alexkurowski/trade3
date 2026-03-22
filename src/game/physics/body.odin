package physics

import "core:math"
import b2 "vendor:box2d"

WID :: b2.WorldId
BID :: b2.BodyId
SID :: b2.ShapeId

Body :: struct {
  bid:  BID,
  size: f32,
}

BodyShape :: enum {
  Box,
  RoundedBox,
  Circle,
}

BodyTransform :: struct {
  position: Vec2,
  velocity: Vec2,
  rotation: f32,
}

create_body :: proc() -> Body {
  body_def := b2.DefaultBodyDef()
  body_def.type = .dynamicBody
  body_def.linearDamping = 6
  body_def.angularDamping = 6
  return Body{bid = b2.CreateBody(world, body_def)}
}

create_static_body :: proc() -> Body {
  body_def := b2.DefaultBodyDef()
  body_def.type = .staticBody
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
  mass: f32 = 1,
  category: CollisionLayer = .None,
  is_sensor: bool = false,
) {
  if size_a <= 0 || size_b <= 0 do panic("Size must be greater than zero")

  half_a := size_a / 2
  half_b := size_b / 2

  body.size = half_a

  shape_def := b2.DefaultShapeDef()
  shape_def.material.friction = 10
  shape_def.material.restitution = 0.2
  shape_def.material.rollingResistance = 0.1
  shape_def.material.tangentSpeed = 0.1
  shape_def.filter.categoryBits = u64(category)
  shape_def.isSensor = is_sensor

  area: f32
  sid: SID
  switch shape {
  case .Box:
    polygon := b2.MakeBox(half_a, half_b)
    sid = b2.CreatePolygonShape(body.bid, shape_def, polygon)
    area = size_a * size_b
  case .RoundedBox:
    polygon := b2.MakeRoundedBox(half_a, half_b, 0.8)
    sid = b2.CreatePolygonShape(body.bid, shape_def, polygon)
    area = size_a * size_b
  case .Circle:
    circle := b2.Circle {
      radius = half_a,
    }
    sid = b2.CreateCircleShape(body.bid, shape_def, circle)
    area = math.PI * (half_a * half_a)
  }

  density := mass / area
  b2.Shape_SetDensity(sid, density, true)
}

add_body_shape :: proc(body: Body, position, size: Vec2) {
  shape_def := b2.DefaultShapeDef()
  shape_def.filter.categoryBits = u64(CollisionLayer.Obstacle)
  polygon := b2.MakeOffsetBox(size.x / 2, size.y / 2, position, b2.MakeRot(0))
  sid := b2.CreatePolygonShape(body.bid, shape_def, polygon)
}

get_position :: proc(body: Body) -> Vec2 {
  return b2.Body_GetPosition(body.bid)
}

get_velocity :: proc(body: Body) -> Vec2 {
  return b2.Body_GetLinearVelocity(body.bid)
}

get_angle :: proc(body: Body) -> f32 {
  rot := b2.Body_GetRotation(body.bid)
  return math.atan2(rot.s, rot.c)
}

get_transform :: proc(body: Body) -> BodyTransform {
  return {position = get_position(body), velocity = get_velocity(body), rotation = get_angle(body)}
}

set_position :: proc(body: Body, position: Vec2, rotation: f32 = 0) {
  b2.Body_SetTransform(body.bid, position, b2.MakeRot(rotation))
}

push :: proc(body: Body, force: Vec2) {
  b2.Body_ApplyForceToCenter(body.bid, force, true)
}

kick :: proc(body: Body, direction: Vec2) {
  b2.Body_SetLinearVelocity(body.bid, 0)
  b2.Body_ApplyLinearImpulseToCenter(body.bid, direction, true)
}

launch_bullet :: proc(body: Body, velocity: Vec2) {
  b2.Body_SetLinearDamping(body.bid, 0)
  b2.Body_SetLinearVelocity(body.bid, velocity)
}

