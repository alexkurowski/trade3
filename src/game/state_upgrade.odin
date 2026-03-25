#+private
package game

import "core:fmt"
import "render"
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
  @(static) mouse_position: Vec2
  mouse_position = rl.GetMousePosition()
  is_hover :: proc(u: ^Upgrade) -> bool {
    SIZE :: 8
    return(
      mouse_position.x > u.position.x - SIZE &&
      mouse_position.x < u.position.x + SIZE &&
      mouse_position.y > u.position.y - SIZE &&
      mouse_position.y < u.position.y + SIZE \
    )
  }

  for &u in g.progress.upgrades.items {
    if is_none(u.id) do continue
    if !upgrade_is_known(&u) do continue

    if upgrade_is_complete(&u) || is_hover(&u) {
      rl.DrawRectangle(i32(u.position.x) - 16, i32(u.position.y) - 16, 32, 32, rl.WHITE)
      render.upgrade(.Star, u.position, color = rl.RED)
    } else if upgrade_is_active(&u) {
      rl.DrawRectangle(i32(u.position.x) - 16, i32(u.position.y) - 16, 32, 32, rl.GRAY)
      render.upgrade(.Star, u.position, color = rl.WHITE)
    } else {
      rl.DrawRectangle(i32(u.position.x) - 16, i32(u.position.y) - 16, 32, 32, rl.DARKGRAY)
      render.upgrade(.Star, u.position, color = rl.WHITE)
    }
  }

  if UI()(ui_root) {
    draw_resources()
    draw_buttons()
  }
}

draw_resources :: proc() {
  if UI()({
    layout = {layoutDirection = .TopToBottom, padding = {8, 8, 8, 8}, childGap = 8},
    floating = {attachTo = .Root, attachment = {element = .RightTop, parent = .RightTop}},
  }) {
    for kind in ResourceKind {
      ui.text(
        fmt.tprintf(
          "%v = %s",
          RESOURCE_LABELS[kind],
          text.format_number(g.progress.inventory.resources[kind]),
        ),
      )
    }
  }
}

draw_buttons :: proc() {
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

  if UI()({
    layout = {layoutDirection = .LeftToRight, padding = {8, 8, 8, 8}, childGap = 8},
    floating = {attachTo = .Root, attachment = {element = .RightBottom, parent = .RightBottom}},
  }) {
    if btn("Exit") {
      set_state(.Quit)
    }
    if btn("Begin round") {
      set_state(.Run)
    }
  }
}

