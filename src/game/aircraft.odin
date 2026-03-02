#+private
package game

import "./render"
import "./ui"
import "core:fmt"
import rl "vendor:raylib"

update_aircraft :: proc(e: ^Entity) {
  if .Player in e.traits {
    update_player_controlled_aircraft(e)
  } else {
    update_ai_controlled_aircraft(e)
  }

  draw_aircraft(e)
}

draw_aircraft :: proc(e: ^Entity) {
  // render.shape(.SphereWires, to_vec3(e.position), e.size, rl.WHITE)
  a := PI / 2 + e.rotation
  render.model(
    .Test,
    to_vec3(e.position),
    rl.QuaternionFromEuler(a, a, a),
    scale = Vec3(1),
    color = {255, 255, 255, 255},
  )
  if .Player in e.traits {
    render.shape(.SphereWires, to_vec3(e.position + at_angle(e.rotation)), 0.01, rl.WHITE)
  }
}

update_player_controlled_aircraft :: proc(e: ^Entity) {
  @(static) THRUST := f32(10)
  @(static) TURN := f32(PI * 1.5)
  @(static) GRAVITY := f32(5)

  // Dampening of velocity
  @(static) MIN_DAMP := f32(0.15)
  @(static) MAX_DAMP := f32(0.35)

  // Gravity factor calculated based on aircraft speed
  //        -----           <- gravity_factor = 1
  //             \
  //              \
  //               \
  //                \______ <- gravity_factor = 0
  //        ^   ^   ^
  // speed: 0  min max       - min/max_speed_gravity
  @(static) MIN_SPEED_GRAVITY := f32(1)
  @(static) MAX_SPEED_GRAVITY := f32(4)

  @(static) MAX_SPEED := f32(6)

  input: struct {
    thrust: bool,
    stop:   bool,
    left:   bool,
    right:  bool,
    shoot:  bool,
  } = {
    thrust = rl.IsKeyDown(.UP) || rl.IsKeyDown(.W),
    stop   = rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S),
    left   = rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A),
    right  = rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D),
    shoot  = rl.IsKeyDown(.SPACE),
  }

  // TODO: More mass will result in
  // - Slower turns
  // - Lower thrust
  // - More fuel consumed (maybe)
  mass_factor := f32(1)

  forward := at_angle(e.rotation)

  // Engine thrust
  if input.thrust {
    e.velocity += forward * THRUST * mass_factor * time.wdt
  }

  // Gravity
  velocity_vector := e.velocity
  if velocity_vector.y < 0 do velocity_vector.y = 0
  gravity_factor := scale(length(velocity_vector), MIN_SPEED_GRAVITY, MAX_SPEED_GRAVITY, 1, 0)
  e.velocity.y -= GRAVITY * gravity_factor * time.wdt

  // Dampen velocity
  pre_damp_y := e.velocity.y
  orientation := abs(cos(e.rotation)) // 0 - horizontal, 1 - vertical
  orientation *= dot(normalize(e.velocity), at_angle(e.rotation))
  if input.stop {
    orientation = clamp(orientation, 0, 0.1)
  } else {
    orientation = clamp(orientation, 0, 1)
  }
  damp_factor := scale(orientation, 0, 1, MAX_DAMP, MIN_DAMP)
  e.velocity *= 1 - damp_factor * time.wdt
  if pre_damp_y < 0 do e.velocity.y = pre_damp_y // Keep y if going down

  if e.position.y < 0 {
    e.velocity.y += 10 * time.wdt
  }

  // Rotation
  if input.left {
    e.rotation += TURN * mass_factor * time.wdt
  } else if input.right {
    e.rotation -= TURN * mass_factor * time.wdt
  }

  // Keep rotation between [0, 2pi)
  if e.rotation >= TAU {
    e.rotation -= TAU
  } else if e.rotation < 0 {
    e.rotation += TAU
  }

  // Clamp velocity
  if length(e.velocity) > MAX_SPEED {
    e.velocity = normalize(e.velocity) * MAX_SPEED
  }

  @(static) shoot_timeout := f32(0)
  shoot_timeout -= time.wdt
  if input.shoot && shoot_timeout <= 0 {
    shoot_timeout = 0.1
    spawn_bullet(
      .None,
      e.position + at_angle(e.rotation) * 0.5,
      e.velocity + at_angle(e.rotation) * 5,
    )
  }

  // Some debug ui
  if UI()({layout = {layoutDirection = .TopToBottom, padding = {4, 4, 32, 32}}}) {
    ui.text(fmt.tprintf("p %.1fx%.1f", e.position.x, e.position.y))
    ui.text(fmt.tprintf("v %.1fx%.1f (%.1f)", e.velocity.x, e.velocity.y, length(e.velocity)))
    ui.text(fmt.tprintf("fov %.1f", g.camera.fovy))
    ui.text(fmt.tprintf("gravity %.1f", gravity_factor))
    ui.text(fmt.tprintf("orientation %.1f", orientation))
    ui.text(fmt.tprintf("damp %.1f", damp_factor))
    ui.text(fmt.tprintf("1. > THRUST %.1f", THRUST))
    ui.text(fmt.tprintf("2. > TURN %.1f", TURN))
    ui.text(fmt.tprintf("3. > GRAVITY %.1f", GRAVITY))
    ui.text(fmt.tprintf("4. > MIN_SPEED_GRAVITY %.1f", MIN_SPEED_GRAVITY))
    ui.text(fmt.tprintf("5. > MAX_SPEED_GRAVITY %.1f", MAX_SPEED_GRAVITY))
    ui.text(fmt.tprintf("6. > MAX_SPEED %.1f", MAX_SPEED))
    ui.text(fmt.tprintf("7. > MIN_DAMP %.1f", MIN_DAMP))
    ui.text(fmt.tprintf("8. > MAX_DAMP %.1f", MAX_DAMP))

    inc, dec := rl.IsKeyDown(.K), rl.IsKeyDown(.J)
    if rl.IsKeyDown(.ONE) {
      if inc do THRUST += time.dt
      if dec do THRUST -= time.dt
    }
    if rl.IsKeyDown(.TWO) {
      if inc do TURN += time.dt
      if dec do TURN -= time.dt
    }
    if rl.IsKeyDown(.THREE) {
      if inc do GRAVITY += time.dt
      if dec do GRAVITY -= time.dt
    }
    if rl.IsKeyDown(.FOUR) {
      if inc do MIN_SPEED_GRAVITY += time.dt
      if dec do MIN_SPEED_GRAVITY -= time.dt
    }
    if rl.IsKeyDown(.FIVE) {
      if inc do MAX_SPEED_GRAVITY += time.dt
      if dec do MAX_SPEED_GRAVITY -= time.dt
    }
    if rl.IsKeyDown(.SIX) {
      if inc do MAX_SPEED += time.dt
      if dec do MAX_SPEED -= time.dt
    }
    if rl.IsKeyDown(.SEVEN) {
      if inc do MIN_DAMP += time.dt
      if dec do MIN_DAMP -= time.dt
    }
    if rl.IsKeyDown(.EIGHT) {
      if inc do MAX_DAMP += time.dt
      if dec do MAX_DAMP -= time.dt
    }
  }
}

update_ai_controlled_aircraft :: proc(e: ^Entity) {
  @(static) THRUST := f32(5)
  @(static) TURN := f32(PI * 2)
  @(static) MAX_SPEED := f32(2)

  target_position := g.player.position
  target_position += at_angle(sin(e.age * 0.1))
  target_angle := angle_between(target_position, e.position)
  if target_angle > PI {
    target_angle -= TAU
  } else if target_angle < -PI {
    target_angle += TAU
  }
  angle_diff := target_angle - e.rotation
  e.rotation += clamp(angle_diff, -TURN * time.wdt, TURN * time.wdt)

  forward := at_angle(e.rotation)
  e.velocity += forward * THRUST * time.wdt

  if length(e.velocity) > MAX_SPEED {
    e.velocity = normalize(e.velocity) * MAX_SPEED
  }

  if e.position.y < 0 {
    e.velocity.y += 10 * time.wdt
  }
}
