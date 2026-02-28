#+private file
package game

// import "./ui"

Tab :: enum {
  Mothership,
  Fleet,
  Crew,
}

current_tab: Tab

@(private)
draw_screen :: proc() {
}
