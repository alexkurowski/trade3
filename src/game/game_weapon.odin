#+private
package game

Weapon :: struct {
  kind:   WeaponKind,
  ammo:   struct {
    current: u16,
    max:     u16,
  },
  fire:   Cooldown,
  reload: struct {
    current:      f32,
    duration:     f32,
    can_qte:      bool,
    qte_start:    f32,
    qte_duration: f32,
  },
  spray:  struct {
    angle:     f32,
    max_angle: f32,
    accuracy:  f32,
    stability: f32,
  },
}

WeaponKind :: enum {
  Raycast,
  Projectile,
}

weapon_set_ammo :: proc(w: ^Weapon, value: u16) {
  w.ammo.max = value
  w.ammo.current = w.ammo.max
}

weapon_start_reload :: proc(w: ^Weapon) {
  w.reload.current += time.wdt
  w.reload.can_qte = true
}

weapon_reload :: proc(w: ^Weapon) {
  w.ammo.current = w.ammo.max
}

weapon_is_reloading :: proc(w: ^Weapon) -> bool {
  return w.reload.current > 0
}

weapon_is_reloading_done :: proc(w: ^Weapon) -> bool {
  return w.reload.current >= w.reload.duration
}

weapon_is_in_qte_window :: proc(w: ^Weapon) -> bool {
  return(
    w.reload.current >= w.reload.qte_start * w.reload.duration &&
    w.reload.current <=
      w.reload.qte_start * w.reload.duration + w.reload.qte_duration * w.reload.duration \
  )
}

