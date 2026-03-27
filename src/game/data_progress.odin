#+private
package game

import cont "containers"

Progress :: struct {
  inventory: Inventory,
  upgrades:  cont.Array(Upgrade, ID, UPGRADE_COUNT),
}

progress_save_to_file :: proc() {
  // TODO: save progress into g.save_slot file
}

progress_load_from_file :: proc(save_slot: u32) {
  success := true
  // TODO: restore progress

  if success {
    g.save_slot = save_slot
  }
}

