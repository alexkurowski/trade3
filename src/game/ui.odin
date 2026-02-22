#+private
package game

import "./ui"
import clay "deps:clay-odin"
import rl "vendor:raylib"

UI :: clay.UI
Style :: clay.ElementDeclaration

grow :: clay.SizingGrow
fit :: clay.SizingFit
fixed :: clay.SizingFixed

sizing_grow := clay.Sizing {
  clay.SizingAxis{type = clay.SizingType.Grow},
  clay.SizingAxis{type = clay.SizingType.Grow},
}

sizing_fit := clay.Sizing {
  clay.SizingAxis{type = clay.SizingType.Fit},
  clay.SizingAxis{type = clay.SizingType.Fit},
}

sizing_row := clay.Sizing {
  clay.SizingAxis{type = clay.SizingType.Grow},
  clay.SizingAxis{type = clay.SizingType.Fit},
}

sizing_col := clay.Sizing {
  clay.SizingAxis{type = clay.SizingType.Fit},
  clay.SizingAxis{type = clay.SizingType.Grow},
}


sizing_fixed_1 := proc(size: f32) -> clay.Sizing {
  return clay.Sizing{clay.SizingFixed(size), clay.SizingFixed(size)}
}
sizing_fixed_2 := proc(widht, height: f32) -> clay.Sizing {
  return clay.Sizing{clay.SizingFixed(widht), clay.SizingFixed(height)}
}
sizing_fixed :: proc {
  sizing_fixed_1,
  sizing_fixed_2,
}

sizing_fullscreen :: proc() -> clay.Sizing {
  return clay.Sizing{clay.SizingFixed(ui.window_width), clay.SizingFixed(ui.window_height)}
}


root := clay.ElementDeclaration {
  layout = {layoutDirection = .TopToBottom, sizing = sizing_grow},
}

padding_1 :: proc(padding: u16) -> clay.Padding {
  return clay.Padding{left = padding, right = padding, top = padding, bottom = padding}
}
padding_2 :: proc(padding_h: u16, padding_v: u16) -> clay.Padding {
  return clay.Padding{left = padding_h, right = padding_h, top = padding_v, bottom = padding_v}
}
padding :: proc {
  padding_1,
  padding_2,
}


border :: proc(width: u16) -> clay.BorderWidth {
  return clay.BorderWidth{left = width, right = width, top = width, bottom = width}
}


stop_propagation :: proc() {
  if clay.Hovered() {
    ui.hovering = true
  }
}

is_hover :: proc() -> bool {
  return clay.Hovered()
}

is_pressed :: proc() -> bool {
  return clay.Hovered() && rl.IsMouseButtonPressed(.LEFT)
}

is_clicked :: proc() -> bool {
  // TODO: proper click
  return clay.Hovered() && rl.IsMouseButtonPressed(.LEFT)
}

