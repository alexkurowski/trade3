#+private file
package game

import "./render"
import "./ui"
import "core:fmt"
import "deps:box"
import rl "vendor:raylib"

player: ^Entity

@(private)
spawn_world :: proc() {
  g.player_id = spawn(.Aircraft, Entity{position = Vec2{0, 10}, traits = {.Player}})

  spawn(.Watercraft, Entity{position = Vec2{20, 0}})

  for i := 0; i < 50; i += 1 {
    spawn_cloud(-20)
  }
}

spawn_cloud :: proc(x: f32 = 0) {
  box.append(
    &g.particles,
    Particle {
      kind = .Cloud,
      position = Vec2{x + randf(20, 40), randf(19, 21)},
      size = randf(1, 2),
      velocity = Vec2{-randf(1, 2), 0},
    },
  )
}

@(private)
update_world :: proc() {
  player = box.get(&g.entities, g.player_id)

  update_player()
  update_entities()
  update_bullets()
  update_particles()

  // Draw waterline
  render.shape(
    .Cube,
    Vec3{player.position.x, -0.1 + sin(time.wt * 2) * 0.1, 0},
    Vec3{100, 0.2, 1},
    rl.WHITE,
  )
  render.shape(.Cube, Vec3{0, 0, 1}, Vec3(1), rl.GRAY)

  if UI()({layout = {padding = {0, 0, 32, 32}}}) {
    ui.text(fmt.tprintf("%.1f %.1f", player.position.x, player.position.y))
  }

  update_camera()
}

update_entities :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue

    e.age += time.dt
    e.position += e.velocity * time.dt

    if e.kind == .Aircraft {
      orientation := abs(sin(e.rotation)) // 0 - horizontal, 1 - vertical
      e.velocity.y -= 1 * orientation * time.dt // gravity

      if e.age > 0.05 {
        e.age = 0
        spawn_particle(
          .AircraftTrail,
          position = e.position + rand_offset(0.01, 0.1),
          velocity = Vec2(0),
          size = randf(0.01, 0.1),
          lifetime = 2,
        )
      }

      render.shape(.SphereWires, to_vec3(e.position), 0.1, rl.WHITE)

      if .Player in e.traits {
        render.shape(.SphereWires, to_vec3(e.position + at_angle(e.rotation)), 0.01, rl.WHITE)
      }
    } else if e.kind == .Watercraft {
      render.shape(.Cube, to_vec3(e.position) + Vec3{0, 0.25, 0}, Vec3{2, 0.5, 0.5}, rl.BLUE)
    }
  }
}

update_bullets :: proc() {
  #reverse for &b, idx in box.every(&g.bullets) {
    b.position += b.velocity * time.dt

    render.shape(.Sphere, to_vec3(b.position), 0.05, rl.RED)

    // Despawn if out of range
    if length(b.position) > 50 {
      box.remove(&g.bullets, i32(idx))
    }
  }
}

update_particles :: proc() {
  cloud_count := 0

  #reverse for &p, idx in box.every(&g.particles) {
    p.position += p.velocity * time.dt
    p.lifetime -= time.dt

    if p.kind == .Cloud {
      cloud_count += 1
      render.shape(.SphereWires, to_vec3(p.position), p.size, rl.Color{255, 255, 255, 64})

      if abs(p.position.x - player.position.x) > 100 {
        box.remove(&g.particles, i32(idx))
      }
    } else if p.kind == .AircraftTrail {
      render.shape(
        .Sphere,
        to_vec3(p.position),
        p.size,
        rl.Color{200, 200, 200, u8(255 * p.lifetime / 2)},
      )

      if abs(p.position.x - player.position.x) > 100 || p.lifetime <= 0 {
        box.remove(&g.particles, i32(idx))
      }
    }
  }

  {
    // Spawn more clouds
    @(static) cloud_spawn_timeout := f32(0)
    cloud_spawn_timeout -= time.dt
    if cloud_count < 1000 && cloud_spawn_timeout <= 0 {
      cloud_spawn_timeout = 1
      spawn_cloud(player.position.x)
    }
  }
}

update_player :: proc() {
  input: struct {
    thrust: bool,
    left:   bool,
    right:  bool,
    shoot:  bool,
  } = {
    thrust = rl.IsKeyDown(.UP) || rl.IsKeyDown(.W),
    left   = rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A),
    right  = rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D),
    shoot  = rl.IsKeyDown(.SPACE),
  }

  if input.thrust {
    player.velocity += at_angle(player.rotation) * 2 * time.dt
  } else {
    orientation := abs(sin(player.rotation)) // 0 - horizontal, 1 - vertical
    glide_factor := 0.98 + 0.02 * (1.0 - orientation) // less velocity reduction in horizontal position
    player.velocity *= glide_factor

    // TODO: Gravity - increase when velocity drops (stall)
    // player.velocity.y = prev_y - 9.8 * (orientation) * time.dt
  }
  clamp_vec(&player.velocity, 2)

  if input.left {
    player.rotation += 4 * time.dt
  }
  if input.right {
    player.rotation -= 4 * time.dt
  }

  @(static) shoot_timeout := f32(0)
  shoot_timeout -= time.dt
  if input.shoot && shoot_timeout <= 0 {
    shoot_timeout = 0.1
    spawn_bullet(
      .None,
      player.position + at_angle(player.rotation) * 0.5,
      player.velocity + at_angle(player.rotation) * 5,
    )
  }
}

update_camera :: proc() {
  g.camera.target = to_vec3(
    player.position + at_angle(player.rotation) * length(player.velocity) * 0.25,
  )

  // Zoom in when closer to ground
  if player.position.y < 5 {
    f := max(0, (5 - player.position.y) * 0.2)
    g.camera.fovy = 30 - f * 10
  } else {
    g.camera.fovy = 30
  }
}
