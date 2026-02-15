#+private
package ui

import clay "deps:clay-odin"
import rl "vendor:raylib"

Vec2 :: [2]f32
Vec3 :: [3]f32
Rect :: rl.Rectangle
Size :: struct {
  width:  f32,
  height: f32,
}

UI :: clay.UI
UIImageData :: struct {
  index: int,
}

UIWindowResizableDirection :: enum {
  None,
  Horizontal,
  Vertical,
  Both,
}

UIWindowResizingOrigin :: enum {
  None,
  Right,
  TopRight,
  Top,
  TopLeft,
  Left,
  BottomLeft,
  Bottom,
  BottomRight,
}

UIWindow :: struct {
  should_close:    bool,
  pressed:         bool,
  dragging:        bool,
  resizable:       UIWindowResizableDirection,
  resizing_origin: UIWindowResizingOrigin,
  hovering_origin: UIWindowResizingOrigin,
  position:        Vec2,
  size:            Size,
}
