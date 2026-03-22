package physics

import b2 "vendor:box2d"

CollisionLayer :: enum u64 {
  None         = 0,
  Player       = 1 << 0,
  Enemy        = 1 << 1,
  Obstacle     = 1 << 2,
  SemiObstacle = 1 << 3,
}

CollisionData :: struct {
  position: Vec3,
  hit:      bool,
  bid:      BID,
}
collision_data: CollisionData

collision_radius :: proc(
  position: Vec3,
  radius: f32,
  mask: CollisionLayer = .None,
) -> ^CollisionData {
  @(static) query_shape_proxy: b2.ShapeProxy = b2.ShapeProxy {
    points = [8]Vec2{},
    count  = 1,
    radius = 1,
  }

  on_collision_callback :: proc "c" (shapeId: b2.ShapeId, data: rawptr) -> bool {
    data := cast(^CollisionData)data
    data.hit = true
    data.bid = b2.Shape_GetBody(shapeId)
    return true
  }

  query_shape_proxy.points[0] = position.xz
  query_shape_proxy.radius = radius

  filter := b2.DefaultQueryFilter()
  filter.maskBits = u64(mask)

  collision_data.position = position
  collision_data.hit = false
  _ = b2.World_OverlapShape(
    world,
    query_shape_proxy,
    filter,
    on_collision_callback,
    &collision_data,
  )
  return &collision_data
}

collision_ray :: proc(position, target: Vec3, mask: CollisionLayer = .None) -> ^CollisionData {
  on_collision_callback :: proc "c" (
    shapeId: b2.ShapeId,
    point: Vec2,
    normal: Vec2,
    fraction: f32,
    data: rawptr,
  ) -> f32 {
    data := cast(^CollisionData)data
    data.hit = true
    data.bid = b2.Shape_GetBody(shapeId)
    return fraction
  }

  filter := b2.DefaultQueryFilter()
  filter.maskBits = u64(mask)

  _ = b2.World_CastRay(
    world,
    position.xz,
    (target - position).xz,
    filter,
    on_collision_callback,
    &collision_data,
  )
  return &collision_data
}

