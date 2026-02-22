#+private file
package game

import "./ui"

@(private)
draw_screen :: proc() {
  root_style :: Style {
    layout = {layoutDirection = .TopToBottom, padding = {16, 16, 12, 12}},
  }
  if UI()(root_style) {
    ui.text("Hello, World!")

    if button("Click me") {
      send_event(.Some, SomeEvent{value = 69420})
    }
  }
}


button :: proc(label: string) -> bool {
  hovered: bool
  clicked: bool

  if UI()({}) {
    hovered = is_hover()
    clicked = is_clicked()
    if UI()({
      layout = {padding = {8, 8, 4, 4}},
      backgroundColor = hovered ? {240, 240, 240, 255} : {40, 45, 50, 255},
    }) {
      ui.text(label, hovered ? .Regular16dim : .Regular16)
    }
  }

  return clicked
}

