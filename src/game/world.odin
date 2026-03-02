#+private file
package game

import "./render"
import "deps:box"
import rl "vendor:raylib"

@(private)
spawn_world :: proc() {
  g.player_id = spawn(.Aircraft, Entity{traits = {.Player}, position = Vec2{0, 10}, size = 0.5})

  for i := 0; i < 10; i += 1 {
    spawn(
      .Aircraft,
      Entity{age = randf(0, 10), position = Vec2{0, 10} + rand_vec2(10), size = 0.25},
    )
  }

  spawn(.Watercraft, Entity{position = Vec2{20, 0}, size = 1})

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
  g.player = box.get(&g.entities, g.player_id)

  update_entities()
  update_bullets()
  update_particles()
  update_waterline()
  update_camera()
}

update_entities :: proc() {
  for &e in g.entities.items {
    if box.is_none(e) do continue

    e.age += time.wdt
    e.position += e.velocity * time.wdt

    switch e.kind {
    case .Aircraft:
      update_aircraft(&e)
    case .Watercraft:
      update_watercraft(&e)
    }

    // if e.age > 0.05 {
    //   e.age = 0

    //   speed := abs(e.velocity.x)
    //   if speed > 0.3 {
    //     spawn_particle(
    //       .AircraftTrail,
    //       position = e.position + rand_offset(0.01, 0.1),
    //       velocity = Vec2(0),
    //       size = speed > 1 ? randf(0.05, 0.1) : randf(0.01, 0.03),
    //       lifetime = speed > 1 ? 2 : 1.5,
    //     )
    //   }
    // }
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

      if abs(p.position.x - g.player.position.x) > 100 {
        box.remove(&g.particles, i32(idx))
      }
    } else if p.kind == .AircraftTrail {
      f := p.lifetime / 2
      render.shape(.Sphere, to_vec3(p.position), p.size * f, rl.Color{200, 200, 200, u8(255 * f)})

      if abs(p.position.x - g.player.position.x) > 100 || p.lifetime <= 0 {
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
      spawn_cloud(g.player.position.x)
    }
  }
}

update_waterline :: proc() {
  render.shape(
    .Cube,
    Vec3{g.player.position.x, sin(PI * time.wt) * 0.1, 0},
    Vec3{100, 0.2, 1},
    rl.WHITE,
  )
  render.shape(.Cube, Vec3{0, 0, 1}, Vec3(1), rl.GRAY)
}

update_camera :: proc() {
  g.camera.target = to_vec3(
    g.player.position + at_angle(g.player.rotation) * length(g.player.velocity) * 0.25,
  )

  if g.debug_mode {
    if rl.IsKeyDown(.M) {
      g.camera.fovy -= 10 * time.dt
    }
    if rl.IsKeyDown(.N) {
      g.camera.fovy += 10 * time.dt
    }
    return
  }

  // Zoom in when closer to ground
  if g.player.position.y < 5 {
    f := max(0, (5 - g.player.position.y) * 0.2)
    g.camera.fovy = 30 - f * 10
  } else {
    g.camera.fovy = 30
  }
}
