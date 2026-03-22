#+private
package game

import cont "containers"
import "physics"

Bullet :: struct {
  kind:     BulletKind,
  from:     BulletOwner,
  position: Vec3,
  velocity: Vec3,
  low:      bool,
}

BulletKind :: enum {
  None,
}

BulletOwner :: enum {
  Player,
  Enemy,
}

spawn_bullet :: proc(from: BulletOwner, position, velocity: Vec3, low: bool = false) {
  height := low ? Vec3{0, 0.2, 0} : Vec3{0, 0.6, 0}
  cont.append(
    &g.bullets,
    Bullet {
      from = from,
      position = position + height + normalize(velocity) / 4,
      velocity = velocity,
      low = low,
    },
  )
}

despawn_bullet :: proc(idx: i32) {
  cont.remove(&g.bullets, idx)
}

despawn_all_bullets :: proc() {
  cont.clear(&g.bullets)
}

get_bullet_collision_mask :: proc(from: BulletOwner, low: bool) -> physics.CollisionLayer {
  if from == .Player {
    if low {
      return .Enemy | .Obstacle | .SemiObstacle
    } else {
      return .Enemy | .Obstacle
    }
  } else {
    if low {
      return .Player | .Obstacle | .SemiObstacle
    } else {
      return .Player | .Obstacle
    }
  }
}

bullet_check_collision_raycast :: proc(
  from: BulletOwner,
  position, target: Vec3,
  low: bool = false,
) -> bool {
  collision := physics.collision_ray(position, target, get_bullet_collision_mask(from, low))
  if collision.hit {
    id := g.body_to_entity[collision.bid]
    e := cont.get(&g.entities, id)
    if e != nil {
      hurt(e, 1)
    }
    return true
  }
  return false
}

bullet_check_collision_radius :: proc(b: ^Bullet) -> bool {
  collision := physics.collision_radius(b.position, 0.5, get_bullet_collision_mask(b.from, b.low))
  if collision.hit {
    id, ok := g.body_to_entity[collision.bid]
    if ok {
      e := cont.get(&g.entities, id)
      if e != nil {
        hurt(e, 1)
      }
    }
    return true
  }
  return false
}

