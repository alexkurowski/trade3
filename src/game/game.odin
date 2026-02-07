#+private file
package game

import "deps:box"

@(private)
start_new_game :: proc() {
  box.clear(&locations)
  box.clear(&vehicles)
  box.clear(&characters)
}

@(private)
game_loop :: proc() {
}
