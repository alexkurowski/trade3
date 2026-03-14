package game

import rl "vendor:raylib"

// NOTE:
// Doesn't work, probably because of all the static variables

@(export)
force_reload :: proc() -> bool {
  return rl.IsKeyPressed(.F5)
}

@(export)
force_restart :: proc() -> bool {
  return rl.IsKeyPressed(.F6)
}

@(export)
memory :: proc() -> rawptr {
  return g
}

@(export)
memory_size :: proc() -> int {
  return size_of(GameMemory)
}

@(export)
hot_reloaded :: proc(mem: rawptr) {
  g = (^GameMemory)(mem)

  // Here you can also set your own global variables. A good idea is to make
  // your global variables into pointers that point to something inside `g`.
}
