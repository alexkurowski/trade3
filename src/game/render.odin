#+private
package game

import "core:math"
import "core:math/linalg"
import "deps:box"
import rl "vendor:raylib"

assets: struct {
  fonts:    struct {
    regular16: rl.Font,
    regular24: rl.Font,
  },
  textures: struct {
    sprites: rl.Texture,
    icons:   rl.Texture,
  },
  shaders:  struct {
    base: rl.Shader,
  },
}

camera: struct {
  c3d:            rl.Camera3D,
  m3d:            rl.Matrix,
  offset:         Vec3,
  target:         Vec3,
  forward:        Vec3,
  right:          Vec3,
  up:             Vec3,
  ground_forward: Vec3,
  ground_right:   Vec3,
  angle:          Vec2,
  distance:       f32,
}
CAMERA_CLOSEST :: 5
CAMERA_FARTHEST :: 250
CAMERA_SPEED :: 4
CAMERA_MIN_PITCH :: -80
CAMERA_MAX_PITCH :: 80

render_load :: proc() {
  assets.fonts.regular16 = rl.LoadFontEx("assets/fonts/Outfit-Regular.ttf", 32, nil, 0)
  assets.fonts.regular24 = rl.LoadFontEx("assets/fonts/Outfit-Regular.ttf", 48, nil, 0)

  assets.textures.sprites = rl.LoadTexture("assets/textures/sprites.png")
  assets.textures.icons = rl.LoadTexture("assets/textures/icons.png")

  assets.shaders.base = rl.LoadShader(
    "assets/shaders/gl330/base_vertex.glsl",
    "assets/shaders/gl330/base_fragment.glsl",
  )

  camera.target = Vec3(0)
  camera.angle = Vec2{225, 45}
  camera.distance = 100
  camera.c3d.fovy = 20
  camera.c3d.projection = .PERSPECTIVE
  camera.c3d.target = Vec3(0)
  camera.c3d.position = Vec3(10)
  camera.c3d.up = Vec3{0, 1, 0}
}

render_step :: proc() {
  // Camera
  camera.distance = math.clamp(camera.distance, CAMERA_CLOSEST, CAMERA_FARTHEST)
  camera.angle.y = math.clamp(camera.angle.y, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)
  // Recalculate camera offset
  a := camera.angle
  camera.offset.x = math.cos(a.y * DEG_TO_RAD) * math.sin(a.x * DEG_TO_RAD)
  camera.offset.y = math.sin(a.y * DEG_TO_RAD)
  camera.offset.z = math.cos(a.y * DEG_TO_RAD) * math.cos(a.x * DEG_TO_RAD)
  camera.offset *= camera.distance
  // Lerp camera
  camera.c3d.target = linalg.lerp(camera.c3d.target, camera.target, CAMERA_SPEED * time.dt)
  camera.c3d.position = linalg.lerp(
    camera.c3d.position,
    camera.c3d.target + camera.offset,
    CAMERA_SPEED * time.dt * 5,
  )
  // Calculate camera matrix
  camera.m3d = rl.GetCameraMatrix(camera.c3d)
  // Recalculate camera directions
  forward := camera.c3d.target - camera.c3d.position
  camera.forward = linalg.normalize(forward)
  camera.right = linalg.normalize(linalg.cross(camera.c3d.up, camera.forward))
  camera.up = linalg.normalize(linalg.cross(camera.forward, camera.right))
  forward.y = 0
  camera.ground_forward = linalg.normalize(forward)
  camera.ground_right = linalg.normalize(linalg.cross(camera.c3d.up, forward))

  // Reset sprite queue
  box.clear(&sprite_queue)
}

render_begin_3d :: proc() {
  rl.BeginMode3D(camera.c3d)
  rl.BeginShaderMode(assets.shaders.base)
}

render_end_3d :: proc() {
  rl.EndShaderMode()
  rl.EndMode3D()
}

render_begin_2d :: proc() {
  // rl.BeginShaderMode(assets.shaders.base)
}

render_end_2d :: proc() {
  rl.EndMode2D()
}


is_on_screen :: #force_inline proc(position: Vec3) -> bool {
  t := rl.Vector3Transform(position, camera.m3d)
  return t.z < -0.1
}

get_screen_position :: #force_inline proc(position: Vec3) -> Vec2 {
  return rl.GetWorldToScreen(position, camera.c3d)
}

to_screen_position :: #force_inline proc(position: Vec3) -> (Vec2, bool) #optional_ok {
  return get_screen_position(position), is_on_screen(position)
}
