#+private
package game

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:time"
import "deps:box"
import rl "vendor:raylib"

EID :: box.ArrayItem
none :: EID{0, 0}

Grid2 :: [2]i32
Vec2 :: [2]f32
Vec3 :: [3]f32
Size :: struct {
  width:  f32,
  height: f32,
}
Rect :: rl.Rectangle
Color :: rl.Color

EPSILON :: 0.00001
DEG_TO_RAD :: math.RAD_PER_DEG
RAD_TO_DEG :: math.DEG_PER_RAD

round :: math.round
floor :: math.floor
ceil :: math.ceil
min :: math.min
max :: math.max
clamp :: math.clamp
pow :: math.pow
sign :: math.sign
sqrt :: math.sqrt

distance :: linalg.distance
length :: linalg.length

shuffle :: rand.shuffle

distance_squared_vec2 :: #force_inline proc(a: Vec2, b: Vec2) -> f32 {
  dx := a.x - b.x
  dy := a.y - b.y
  return dx * dx + dy * dy
}
distance_squared_vec3 :: #force_inline proc(a: Vec3, b: Vec3) -> f32 {
  dx := a.x - b.x
  dy := a.y - b.y
  dz := a.z - b.z
  return dx * dx + dy * dy + dz * dz
}
distance_squared :: proc {
  distance_squared_vec2,
  distance_squared_vec3,
}

rotate_vec2 :: proc(v: ^Vec2, angle: f32) {
  cos_a := math.cos(angle)
  sin_a := math.sin(angle)
  x := v.x * cos_a - v.y * sin_a
  y := v.x * sin_a + v.y * cos_a
  v.x = x
  v.y = y
}
rotate_vec3 :: proc(v: ^Vec3, angle: f32) {
  cos_a := math.cos(angle)
  sin_a := math.sin(angle)
  x := v.x * cos_a - v.z * sin_a
  z := v.x * sin_a + v.z * cos_a
  v.x = x
  v.z = z
}
rotate :: proc {
  rotate_vec2,
  rotate_vec3,
}

is_zero_f32 :: proc(v: f32) -> bool {
  return abs(v) < EPSILON
}
is_zero_vec2 :: proc(v: Vec2) -> bool {
  return abs(v.x) < EPSILON && abs(v.y) < EPSILON
}
is_zero_vec3 :: proc(v: Vec3) -> bool {
  return abs(v.x) < EPSILON && abs(v.y) < EPSILON && abs(v.z) < EPSILON
}
is_zero :: proc {
  is_zero_f32,
  is_zero_vec2,
  is_zero_vec3,
}

normalize_vec2 :: proc(v: Vec2) -> Vec2 {
  length := math.sqrt(v.x * v.x + v.y * v.y)
  if length < EPSILON {
    return Vec2{0, 0}
  }
  return Vec2{v.x / length, v.y / length}
}
normalize_vec3 :: proc(v: Vec3) -> Vec3 {
  length := math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
  if length < EPSILON {
    return Vec3{0, 0, 0}
  }
  return Vec3{v.x / length, v.y / length, v.z / length}
}
normalize :: proc {
  normalize_vec2,
  normalize_vec3,
}

to_vec2 :: proc(v: Vec3) -> Vec2 {
  return Vec2{v.x, v.z}
}
to_vec3 :: proc(v: Vec2, y: f32 = 0) -> Vec3 {
  return Vec3{v.x, y, v.y}
}

angle_between_vec2 :: proc(a: Vec2, b: Vec2) -> f32 {
  return math.atan2(a.y - b.y, a.x - b.x)
}
angle_between_vec3 :: proc(a: Vec3, b: Vec3) -> f32 {
  return math.atan2(a.z - b.z, a.x - b.x)
}
angle_between :: proc {
  angle_between_vec2,
  angle_between_vec3,
}

clamp_vec :: proc(vec: ^$Vec/[$N]$E, max: E) {
  len := linalg.length(vec^)

  if len > max {
    vec^ = linalg.normalize(vec^) * max
  }
}

perpendicular_vec2 :: proc(v: Vec2) -> Vec2 {
  return Vec2{-v.y, v.x}
}
perpendicular_vec3 :: proc(v: Vec3) -> Vec3 {
  return Vec3{-v.z, v.y, v.x}
}
perpendicular :: proc {
  perpendicular_vec2,
  perpendicular_vec3,
}


// === Randoms ===
rand :: proc() -> f32 {
  return rand.float32()
}
randi :: proc(min, max: i32) -> i32 {
  return rand.int32_range(min, max + 1)
}
randf :: proc(min, max: f32) -> f32 {
  return rand.float32_range(min, max)
}

randu_bell :: proc(min, max: u16, bell_curve: int) -> u16 {
  total: f32 = 0
  for i := 0; i < bell_curve; i += 1 {
    total += rand.float32_range(f32(min), f32(max))
  }
  return u16(total / f32(bell_curve))
}
randi_bell :: proc(min, max: i32, bell_curve: int) -> i32 {
  total: f32 = 0
  for i := 0; i < bell_curve; i += 1 {
    total += rand.float32_range(f32(min), f32(max))
  }
  return i32(total / f32(bell_curve))
}
randf_bell :: proc(min, max: f32, bell_curve: int) -> f32 {
  total: f32 = 0
  for i := 0; i < bell_curve; i += 1 {
    total += randf(min, max)
  }
  return total / f32(bell_curve)
}
randf_sqrt :: proc(min, max: f32) -> f32 {
  return min + (max - min) * math.sqrt(rand.float32())
}
randf_isqrt :: proc(min, max: f32) -> f32 {
  return min + (max - min) * (1 - math.sqrt(rand.float32()))
}

randb :: proc(chance: f32 = 0.5) -> bool {
  return rand.float32() < chance
}

rand_angle :: proc() -> f32 {
  return rand.float32_range(0, math.TAU)
}
at_angle :: proc(angle: f32, y: f32 = 0) -> Vec3 {
  return Vec3{math.cos(angle), y, math.sin(angle)}
}
rand_vec2 :: proc(distance: f32) -> Vec2 {
  angle := rand_angle()
  return Vec2{math.cos(angle), math.sin(angle)} * distance
}
rand_vec3 :: proc(distance: f32) -> Vec3 {
  angle := rand_angle()
  return Vec3{math.cos(angle), 0, math.sin(angle)} * distance
}
rand_offset :: proc(min, max: f32) -> Vec2 {
  angle := rand_angle()
  return Vec2{math.cos(angle), math.sin(angle)} * randf(min, max)
}

rand_choice_any :: proc(arr: []$T) -> T {
  return rand.choice(arr)
}
rand_choice_not :: proc(arr: []$T, not: ^map[T]bool) -> T {
  for {
    out := rand.choice(arr)
    if not == nil {
      return out
    }
    if _, found := not[out]; !found {
      return out
    }
  }
}
rand_choice :: proc {
  rand_choice_any,
  rand_choice_not,
}


// === Easing ===
ease_in_out_cubic :: proc(x: f32) -> f32 {
  return x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2
}


// === Debug ===
p :: proc(x: any, name := #caller_expression(x)) {
  fmt.printf("%v = %#v", name, x)
}
pp :: proc(prefix: string, v: any) {
  fmt.printf(">>> %s: %#v\n", prefix, v)
}

bench_first :: proc() -> time.Time {
  return time.now()
}
bench_next :: proc(prefix: string, prev: time.Time) -> time.Time {
  pp(prefix, time.duration_milliseconds(time.diff(prev, time.now())))
  return time.now()
}
bench :: proc {
  bench_first,
  bench_next,
}
