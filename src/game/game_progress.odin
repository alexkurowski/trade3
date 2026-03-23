#+private
package game

Progress :: struct {
  inventory:     Inventory,
  pickup_radius: f32,
}

ResourceKind :: enum {
  A,
  B,
  C,
  D,
  E,
  F,
}

Inventory :: struct {
  resources: [ResourceKind]u64,
}

