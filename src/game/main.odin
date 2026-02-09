package game

import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

INITIAL_WINDOW_WIDTH :: 800
INITIAL_WINDOW_HEIGHT :: 600

load :: proc() {
  text_load()
  render_load()
  ui_load(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT)

  start_new_game()
}

unload :: proc() {
  ui_unload()
}

update :: proc() {
  rl.BeginDrawing()
  rl.ClearBackground(rl.BLACK)

  time_update()
  ui_update()
  render_update()
  ui_begin()
  rl.BeginMode3D(camera.c3d)
  rl.BeginShaderMode(assets.shaders.base)
  game_loop()
  rl.EndShaderMode()
  rl.EndMode3D()
  render_sprites()
  ui_end()
  draw_debug_2d()

  free_all(context.temp_allocator)
  rl.EndDrawing()
}

// #region Debug procedures
debug_mode := true

draw_debug_3d :: proc() {
  @(static) position := Vec3{1, 0, 1}
  {
    // Player sprite test
    @(static) flip := false
    input: Vec3
    velocity: Vec3
    if rl.IsKeyDown(.A) {
      input.x -= 1
      flip = true
    }
    if rl.IsKeyDown(.D) {
      input.x += 1
      flip = false
    }
    if rl.IsKeyDown(.W) do input.z -= 1
    if rl.IsKeyDown(.S) do input.z += 1
    if input.x != 0 || input.z != 0 {
      velocity = linalg.normalize(
        camera.ground_forward * -input.z + camera.ground_right * -input.x,
      )
      position += velocity * time.dt
      camera.target = position
    }

    rl.DrawBillboardPro(
      camera.c3d,
      assets.textures.sprites,
      Rect{16 + (flip ? 16 : 0), 0, 16 * (flip ? -1 : 1), 16},
      position,
      camera.up,
      Vec2(1),
      Vec2{0.5, 0.125}, // 0.125 is 1 / 16 * 2 (2 pixels up)
      0,
      rl.WHITE,
    )
    rl.DrawCircle3D(position, 0.5, Vec3{1, 0, 0}, 90, rl.RED)
    rl.DrawLine3D(position, position + velocity, rl.RED)
  }

  {
    // Player gun sprite test
    @(static) flip := false
    @(static) angle := f32(0)
    ray := rl.GetScreenToWorldRay(rl.GetMousePosition(), camera.c3d)
    collision := rl.GetRayCollisionQuad(
      ray,
      Vec3{-10000, 0, -10000},
      Vec3{10000, 0, -10000},
      Vec3{10000, 0, 10000},
      Vec3{-10000, 0, 10000},
    )
    if collision.hit {
      position_2d := rl.GetWorldToScreen(position, camera.c3d)
      target_2d := rl.GetWorldToScreen(collision.point, camera.c3d)
      angle = -angle_between(target_2d, position_2d) * RAD_TO_DEG
      flip = angle > 90 || angle < -90
    }
    gun_position := position
    gun_position += camera.forward * -0.2 + camera.up * 0.2
    gun_position +=
      camera.right * math.cos(angle * DEG_TO_RAD) * -0.1 +
      camera.up * math.sin(angle * DEG_TO_RAD) * 0.1
    gun_scale :: 0.75

    rl.DrawBillboardPro(
      camera.c3d,
      assets.textures.sprites,
      Rect{32, 0 + (flip ? 16 : 0), 16, 16 * (flip ? -1 : 1)},
      gun_position,
      camera.up,
      Vec2(1) * gun_scale,
      Vec2{0.5, 0.5} * gun_scale,
      angle,
      rl.WHITE,
    )
  }

  {
    // Camera rotation test
    pan: Vec2
    zoom: f32
    if rl.IsKeyDown(.LEFT_SHIFT) {
      zoom = -rl.GetMouseWheelMoveV().y
    } else {
      pan = rl.GetMouseWheelMoveV() * 2.5
    }
    camera.angle.x += pan.x
    camera.angle.y -= pan.y
    camera.distance += zoom
  }

  if debug_mode {
    rl.EndShaderMode()
    rl.DrawGrid(20, 1)
  }
}

draw_debug_2d :: proc() {
  if rl.IsKeyPressed(.SLASH) {
    debug_mode = !debug_mode
  }

  rl.DrawTextEx(
    assets.fonts.regular24,
    fmt.ctprintf("CAM: [%1.f, %1.f - %.1f]", camera.angle.x, camera.angle.y, camera.distance),
    Vec2{0, 20},
    16,
    0,
    rl.WHITE,
  )
  if debug_mode {
    rl.DrawFPS(0, 0)
  }
}

draw_debug_ui :: proc() {
  if UI()({layout = {padding = {32, 32, 32, 32}}, backgroundColor = {0, 0, 0, 255}}) {
    text("Hello, World!", .Regular24)
  }
}
// #endregion
