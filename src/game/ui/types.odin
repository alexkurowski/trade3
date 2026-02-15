#+private
package ui

import clay "deps:clay-odin"
import rl "vendor:raylib"

UI :: clay.UI
Style :: clay.ElementDeclaration

Vec2 :: [2]f32
Vec3 :: [3]f32
Rect :: rl.Rectangle
Size :: struct {
  width:  f32,
  height: f32,
}
