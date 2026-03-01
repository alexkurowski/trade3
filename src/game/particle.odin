#+private
package game

import "deps:box"

Particle :: struct {
  kind:         ParticleKind,
  position:     Vec2,
  velocity:     Vec2,
  acceleration: Vec2,
  size:         f32,
  lifetime:     f32,
}

ParticleKind :: enum {
  None,
  Cloud,
  AircraftTrail,
}

spawn_particle :: proc(
  kind: ParticleKind,
  position: Vec2,
  velocity: Vec2,
  size: f32,
  lifetime: f32,
) {
  box.append(
    &g.particles,
    Particle {
      kind = kind,
      position = position,
      velocity = velocity,
      size = size,
      lifetime = lifetime,
    },
  )
}
