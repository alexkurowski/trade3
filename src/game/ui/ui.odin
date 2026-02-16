package ui

import clay "deps:clay-odin"
import rl "vendor:raylib"


hovering: bool
tooltip: Maybe(string)
window_width: f32
window_height: f32


load :: proc(width, height: f32) {
  prepare_colors()
  prepare_sprites()
  load_fonts_from_disk()
  create_font_variants_for_ui()
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


// ## UI sprites
SpriteType :: enum u8 {
  Close,
  Cog,
  Play,
  FFPlay,
  FFFPlay,
  Pause,
  Dropdown,
  CaretLeft,
  CaretRight,
  DoubleCaretLeft,
  DoubleCaretRight,
  Skip01,
  Skip02,
  Skip03,
  Skip04,
  Skip05,
  WindowHoverRight,
  WindowHoverTopRight,
  WindowHoverTop,
  WindowHoverTopLeft,
  WindowHoverLeft,
  WindowHoverBottomLeft,
  WindowHoverBottom,
  WindowHoverBottomRight,
}
UserDataSprite :: struct {
  index: int,
}
ui_sprite := map[SpriteType]UserDataSprite{}
prepare_sprites :: proc() {
  for sprite in SpriteType {
    ui_sprite[sprite] = UserDataSprite {
      index = int(sprite),
    }
  }
}
// #endregion


// #region Components
text_const :: proc($str: string, variant: FontVariant = .Regular16, _: bool = true) {
  clay.Text(str, &font_configs[variant])
}
text_var :: proc(str: string, variant: FontVariant = .Regular16) {
  clay.TextDynamic(str, &font_configs[variant])
}
// Draw text
text :: proc {
  text_const,
  text_var,
}

draw_tooltip :: proc(str: string) {
  mouse_position := rl.GetMousePosition()
  if UI()({
    layout = {
      sizing = {{type = clay.SizingType.Fit}, {type = clay.SizingType.Fit}},
      padding = {8, 8, 4, 4},
    },
    backgroundColor = color.window_background_end,
    border = {width = {left = 1, right = 1, top = 1, bottom = 1}, color = color.window_border},
    floating = {attachTo = .Root, offset = {mouse_position.x + 10, mouse_position.y + 10}},
  }) {
    text(str)
  }
}

spacer :: proc() {
  UI()({layout = {sizing = {clay.SizingGrow(), clay.SizingFit()}}})
}
// #endregion
