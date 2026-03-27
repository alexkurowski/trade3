#+private
package game

import cont "containers"

UpgradeEventKind :: enum {
  PlayerHitEnemy,
  PlayerTookDamage,
}

@(private = "file")
active_upgrades: [UpgradeEventKind]cont.Pool(ID, 64)

send_event :: proc(kind: UpgradeEventKind, id: ID) {
  for &uid in cont.every(&active_upgrades[kind]) {
    upgrade := cont.get(&g.progress.upgrades, uid)
    if upgrade == nil do continue
    upgrade.apply(upgrade, id)
  }
}

//
// Upgrade-related events
//

subscribe_event :: proc(kind: UpgradeEventKind, id: ID) {
  cont.append(&active_upgrades[kind], id)
}

clear_all_subscribed_events :: proc() {
  for kind in UpgradeEventKind {
    cont.clear(&active_upgrades[kind])
  }
}

