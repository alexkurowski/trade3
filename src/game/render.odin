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
CAMERA_FARTHEST :: 50
CAMERA_SPEED :: 4
CAMERA_MIN_PITCH :: -80
CAMERA_MAX_PITCH :: 80

Sprite :: struct {
  type:     SpriteType,
  position: Vec2,
}

SpriteType :: enum u8 {
  None,
  Circle,
  Square,
  TriangleUp,
  TriangleRight,
}

@(private = "file")
sprite_queue: box.Pool(Sprite, 256)

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
  camera.distance = 30
  camera.c3d.fovy = 20
  camera.c3d.projection = .PERSPECTIVE
  camera.c3d.target = Vec3(0)
  camera.c3d.position = Vec3(10)
  camera.c3d.up = Vec3{0, 1, 0}
}

render_update :: proc() {
  // Camera
  camera.distance = math.clamp(camera.distance, CAMERA_CLOSEST, CAMERA_FARTHEST)
  camera.angle.y = math.clamp(camera.angle.y, CAMERA_MIN_PITCH, CAMERA_MAX_PITCH)
  // Recalculate camera offset
  d, a := camera.distance, camera.angle
  camera.offset.x = d * math.cos(a.y * DEG_TO_RAD) * math.sin(a.x * DEG_TO_RAD)
  camera.offset.y = d * math.sin(a.y * DEG_TO_RAD)
  camera.offset.z = d * math.cos(a.y * DEG_TO_RAD) * math.cos(a.x * DEG_TO_RAD)
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

render_finish :: proc() {
  for sprite in box.every(&sprite_queue) {
    source := Rect{0, 0, 32, 32}
    switch sprite.type {
    case .None:
    // NOP
    case .Circle:
      source.x = 32
    case .Square:
      source.x = 64
    case .TriangleUp:
      source.x = 96
    case .TriangleRight:
      source.x = 128
    }
    rl.DrawTexturePro(
      assets.textures.icons,
      source,
      Rect{sprite.position.x, sprite.position.y, 16, 16},
      Vec2{8, 8},
      0,
      rl.WHITE,
    )
  }
}

draw_sprite :: proc {
  draw_sprite_vec2,
  draw_sprite_vec3,
}
draw_sprite_vec2 :: proc(type: SpriteType, position: Vec2) {
  box.append(&sprite_queue, Sprite{type, position})
}
draw_sprite_vec3 :: proc(type: SpriteType, position: Vec3) {
  if is_on_screen(position) {
    box.append(&sprite_queue, Sprite{type, to_screen_position(position)})
  }
}

draw_plane_line :: proc(position: Vec3) {
  p1 := position
  if p1.y > 0.2 {
    p1.y -= 0.2
  } else if p1.y < -0.2 {
    p1.y += 0.2
  } else {
    return
  }
  p2 := Vec3{p1.x, 0, p1.z}
  rl.DrawLine3D(p1, p2, rl.WHITE)
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
