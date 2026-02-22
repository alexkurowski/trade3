package ui

import clay "deps:clay-odin"
import rl "vendor:raylib"


hovering: bool
tooltip: Maybe(string)
window_width: f32
window_height: f32

is_hover :: clay.Hovered


load :: proc(width, height: f32) {
  load_fonts_from_disk()
  init_raylib_implementation(width, height)

  window_width = width
  window_height = height
}

unload :: proc() {
  unload_raylib_implementation()
  unload_fonts()
}

begin :: proc(dt: f32) {
  hovering = false
  tooltip = nil

  mouse_position := rl.GetMousePosition()
  clay.SetPointerState(
    {mouse_position.x, mouse_position.y},
    rl.IsMouseButtonDown(.LEFT) || rl.IsMouseButtonDown(.RIGHT),
  )
  clay.UpdateScrollContainers(false, rl.GetMouseWheelMoveV(), dt)

  {
    dpi := rl.GetWindowScaleDPI()
    new_width := f32(rl.GetRenderWidth()) / dpi.x
    new_height := f32(rl.GetRenderHeight()) / dpi.y
    if new_width != window_width || new_height != window_height {
      window_width = new_width
      window_height = new_height
      clay.SetLayoutDimensions({window_width, window_height})
    }
  }

  // Clay debug toggle
  if rl.IsKeyDown(.LEFT_ALT) &&
     (rl.IsKeyDown(.LEFT_SUPER) || rl.IsKeyDown(.LEFT_CONTROL)) &&
     rl.IsKeyPressed(.I) {
    clay.SetDebugModeEnabled(!clay.IsDebugModeEnabled())
  }

  clay.BeginLayout()
}

end :: proc() {
  if str, ok := tooltip.?; ok {
    draw_tooltip(str)
  }
  layout := clay.EndLayout()
  render(&layout)
}


// #region UI option structs
UserDataType :: enum u8 {
  PanelGradient = 0,
}
ClayUserDataType :: struct {
  type: UserDataType,
}
panel_gradient := ClayUserDataType {
  type = .PanelGradient,
}


// #region Components
text_const :: proc(
  $str: string,
  color: Color = 0,
  font: TextFont = .Regular,
  size: u16 = 16,
  _: bool = true,
) {
  ptr := new_clone(
    clay.TextElementConfig{textColor = color, fontId = u16(font), fontSize = u16(size)},
    context.temp_allocator,
  )
  clay.Text(str, ptr)
}
text_var :: proc(str: string, color: Color = 0, font: TextFont = .Regular, size: u16 = 16) {
  ptr := new_clone(
    clay.TextElementConfig{textColor = color, fontId = u16(font), fontSize = u16(size)},
    context.temp_allocator,
  )
  clay.TextDynamic(str, ptr)
}
// Draw text
text :: proc {
  text_const,
  text_var,
}

icon :: proc(index: i32, color: [4]f32, size: f32 = 16) {
  ptr := new_clone(UIImageData{index = index}, context.temp_allocator)
  clay.UI()({
    layout = {sizing = {clay.SizingFixed(size), clay.SizingFixed(size)}},
    image = {imageData = ptr},
    backgroundColor = color,
  })
}

draw_tooltip :: proc(str: string) {
  mouse_position := rl.GetMousePosition()
  if UI()({
    layout = {
      sizing = {{type = clay.SizingType.Fit}, {type = clay.SizingType.Fit}},
      padding = {8, 8, 4, 4},
    },
    backgroundColor = {250, 120, 100, 255},
    border = {width = {left = 1, right = 1, top = 1, bottom = 1}, color = {255, 0, 0, 255}},
    floating = {attachTo = .Root, offset = {mouse_position.x + 10, mouse_position.y + 10}},
  }) {
    text(str)
  }
}

space :: proc() {
  UI()({layout = {sizing = {clay.SizingGrow(), clay.SizingFit()}}})
}
// #endregion

