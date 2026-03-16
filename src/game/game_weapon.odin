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
    duration:  f32,
    qte_start: f32,
    qte_end:   f32,
  },
  spray:  struct {
    radius:     f32,
    max_radius: f32,
    accuracy:   f32,
    stability:  f32,
  },
}

WeaponKind :: enum {
  Raycast,
  Projectile,
}

