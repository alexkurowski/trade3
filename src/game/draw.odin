#+private file
package game

import "./ui"

@(private)
draw_screen :: proc() {
  root_style := Style {
    layout = {
      sizing = {grow(), grow()},
      layoutDirection = .TopToBottom,
      padding = {16, 16, 12, 12},
    },
  }
  if UI()(root_style) {
    tabs()
    ui.text("Hello, World!")

    if button("Click me", 0) {
      send_event(.Some, SomeEvent{value = 69420})
    }
  }
}

tabs :: proc() {
  if UI()({layout = {sizing = {grow(), fit()}, padding = {8, 8, 4, 4}, childGap = 8}}) {
    button("Mothership", 1)
    ui.space()
    button("Fleet", 2)
    ui.space()
    button("Crew", 3)
  }
}

button :: proc(label: string, icon_index: i32) -> bool {
  hovered: bool
  clicked: bool

  if UI()({}) {
    hovered = is_hover()
    clicked = is_clicked()
    if UI()({
      layout = {padding = {8, 8, 4, 4}, childAlignment = {.Center, .Center}, childGap = 8},
      backgroundColor = hovered ? {240, 240, 240, 255} : {0, 0, 0, 0},
    }) {
      ui.icon(icon_index, hovered ? {0, 0, 0, 255} : {240, 240, 240, 255})
      ui.text(
        label,
        font = .Regular,
        size = 18,
        color = hovered ? {0, 0, 0, 255} : {240, 240, 240, 255},
      )
    }
  }

  return clicked
}

