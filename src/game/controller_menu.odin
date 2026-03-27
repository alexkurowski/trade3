#+private
package game

import "ui"
import rl "vendor:raylib"

state_menu_ready :: proc() {
  rl.ShowCursor()
}

state_menu :: proc() {
  btn :: proc(label: string) -> bool {
    hover, click: bool

    if UI()({}) {
      hover = is_hovered()
      if UI()({
        layout = {padding = {8, 8, 4, 4}},
        backgroundColor = hover ? {40, 40, 40, 255} : {10, 10, 10, 255},
      }) {
        click = hover && is_pressed()
        ui.text(label)
      }
    }
    return click
  }

  if UI()({layout = {layoutDirection = .TopToBottom, padding = {8, 8, 8, 8}, childGap = 8}}) {
    if btn("Start Game") {
      set_state(.Upgrade)
    }
    if btn("Exit") {
      set_state(.Quit)
    }
  }
}

