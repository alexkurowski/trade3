package main

import "core:c/libc"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:time"

main :: proc() {
  // Set working dir to dir of executable.
  exe_path := os.args[0]
  exe_dir := filepath.dir(string(exe_path), context.temp_allocator)
  os.set_working_directory(exe_dir)

  context.logger = log.create_console_logger()

  default_allocator := context.allocator
  tracking_allocator: mem.Tracking_Allocator
  mem.tracking_allocator_init(&tracking_allocator, default_allocator)
  context.allocator = mem.tracking_allocator(&tracking_allocator)

  reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
    err := false

    for _, value in a.allocation_map {
      log.errorf("%v: Leaked %v bytes\n", value.location, value.size)
      err = true
    }

    mem.tracking_allocator_clear(a)
    return err
  }

  game_api_version := 0
  game_api, game_api_ok := load_game_api(game_api_version)

  if !game_api_ok {
    fmt.println("Failed to load Game API")
    return
  }

  game_api_version += 1
  game_api.open_window()
  game_api.load()

  old_game_apis := make([dynamic]GameApi, default_allocator)

  for game_api.is_running() {
    game_api.update()
    force_reload := game_api.force_reload()
    force_restart := game_api.force_restart()
    reload := force_reload || force_restart
    game_dll_mod, game_dll_mod_err := os.last_write_time_by_name(GAME_DLL_PATH)

    if game_dll_mod_err == os.ERROR_NONE && game_api.modification_time != game_dll_mod {
      reload = true
    }

    if reload {
      new_game_api, new_game_api_ok := load_game_api(game_api_version)

      if new_game_api_ok {
        force_restart = force_restart || game_api.memory_size() != new_game_api.memory_size()

        if !force_restart {
          // This does the normal hot reload

          // Note that we don't unload the old game APIs because that
          // would unload the DLL. The DLL can contain stored info
          // such as string literals. The old DLLs are only unloaded
          // on a full reset or on shutdown.
          append(&old_game_apis, game_api)
          game_memory := game_api.memory()
          game_api = new_game_api
          game_api.hot_reloaded(game_memory)
        } else {
          // This does a full reset. That's basically like opening and
          // closing the game, without having to restart the executable.
          //
          // You end up in here if the game requests a full reset OR
          // if the size of the game memory has changed. That would
          // probably lead to a crash anyways.

          game_api.unload()
          reset_tracking_allocator(&tracking_allocator)

          for &g in old_game_apis {
            unload_game_api(&g)
          }

          clear(&old_game_apis)
          unload_game_api(&game_api)
          game_api = new_game_api
          game_api.load()
        }

        game_api_version += 1
      }
    }

    if len(tracking_allocator.bad_free_array) > 0 {
      for b in tracking_allocator.bad_free_array {
        log.errorf("Bad free at: %v", b.location)
      }

      // This prevents the game from closing without you seeing the bad
      // frees. This is mostly needed because I use Sublime Text and my game's
      // console isn't hooked up into Sublime's console properly.
      libc.getchar()
      panic("Bad free detected")
    }
  }

  free_all(context.temp_allocator)
  game_api.unload()
  if reset_tracking_allocator(&tracking_allocator) {
    // This prevents the game from closing without you seeing the memory
    // leaks. This is mostly needed because I use Sublime Text and my game's
    // console isn't hooked up into Sublime's console properly.
    libc.getchar()
  }

  for &g in old_game_apis {
    unload_game_api(&g)
  }

  delete(old_game_apis)

  game_api.close_window()
  unload_game_api(&game_api)
  mem.tracking_allocator_destroy(&tracking_allocator)
}

// Make game use good GPU on laptops.
@(export)
NvOptimusEnablement: u32 = 1
@(export)
AmdPowerXpressRequestHighPerformance: i32 = 1
