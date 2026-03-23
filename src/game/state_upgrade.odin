#+private
package game

import "core:fmt"
import "text"
import "ui"
import rl "vendor:raylib"

RESOURCE_LABELS := [ResourceKind]string {
  .A = "A",
  .B = "B",
  .C = "C",
  .D = "D",
  .E = "E",
  .F = "F",
}

state_upgrade_ready :: proc() {
  rl.ShowCursor()
}

state_upgrade :: proc() {
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
    for kind in ResourceKind {
      ui.text(
        fmt.tprintf(
          "%v = %s",
          RESOURCE_LABELS[kind],
          text.format_number(g.progress.inventory.resources[kind]),
        ),
      )
    }
    if btn("Begin round") {
      set_state(.Run)
    }
    if btn("Exit") {
      set_state(.Quit)
    }
  }
}

