package main

import "core:dynlib"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:time"

when ODIN_OS == .Windows {
  DLL_EXT :: ".dll"
} else when ODIN_OS == .Darwin {
  DLL_EXT :: ".dylib"
} else {
  DLL_EXT :: ".so"
}

GAME_DLL_DIR :: "./out/"
GAME_DLL_PATH :: GAME_DLL_DIR + "game" + DLL_EXT

GameApi :: struct {
  lib:               dynlib.Library,
  load:              proc(),
  unload:            proc(),
  update:            proc(),
  is_running:        proc() -> bool,
  open_window:       proc(),
  close_window:      proc(),
  memory:            proc() -> rawptr,
  memory_size:       proc() -> int,
  hot_reloaded:      proc(mem: rawptr),
  force_reload:      proc() -> bool,
  force_restart:     proc() -> bool,
  modification_time: time.Time,
  api_version:       int,
}

load_game_api :: proc(api_version: int) -> (api: GameApi, ok: bool) {
  mod_time, mod_time_error := os.last_write_time_by_name(GAME_DLL_PATH)
  if mod_time_error != os.ERROR_NONE {
    fmt.printfln(
      "Failed getting last write time of " + GAME_DLL_PATH + ", error code: {1}",
      mod_time_error,
    )
    return
  }

  game_dll_name := fmt.tprintf(GAME_DLL_DIR + "game_{0}" + DLL_EXT, api_version)
  copy_dll(game_dll_name) or_return

  // This proc matches the names of the fields in GameApi to symbols in the
  // game DLL. It actually looks for symbols starting with `game_`, which is
  // why the argument `"game_"` is there.
  _, ok = dynlib.initialize_symbols(&api, game_dll_name, "", "lib")
  if !ok {
    fmt.printfln("Failed initializing symbols: {0}", dynlib.last_error())
  }

  api.api_version = api_version
  api.modification_time = mod_time
  ok = true

  return
}

unload_game_api :: proc(api: ^GameApi) {
  if api.lib != nil {
    if !dynlib.unload_library(api.lib) {
      fmt.printfln("Failed unloading lib: {0}", dynlib.last_error())
    }
  }

  if os.remove(fmt.tprintf(GAME_DLL_DIR + "game_{0}" + DLL_EXT, api.api_version)) != nil {
    fmt.printfln("Failed to remove {0}game_{1}" + DLL_EXT + " copy", GAME_DLL_DIR, api.api_version)
  }
}

// We copy the DLL because using it directly would lock it, which would prevent
// the compiler from writing to it.
copy_dll :: proc(to: string) -> bool {
  copy_err := os.copy_file(to, GAME_DLL_PATH)

  if copy_err != nil {
    fmt.printfln("Failed to copy " + GAME_DLL_PATH + " to {0}: %v", to, copy_err)
    return false
  }

  return true
}
