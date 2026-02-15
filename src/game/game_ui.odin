#+private
package game

import "core:slice"
import "core:strings"
import "deps:box"

draw_ui :: proc() {
  draw_ui_location_breadcrumb :: proc() {
    location := box.get(&w.locations, g.location_view_id)
    if location == nil do return

    path: box.Pool(string, 4)

    for location != nil {
      box.append(&path, location.name)
      location = box.get(&w.locations, location.parent_id)
    }

    slice.reverse(box.every(&path))

    if !box.is_empty(&path) {
      if UI()({}) {
        ui_text(strings.join(box.every(&path), " > ", context.temp_allocator))
      }
    }
  }

  draw_ui_location_breadcrumb()
}
