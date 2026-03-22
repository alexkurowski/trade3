#+private
package game

Upgrades :: struct {
  resources: [Resource]u64,
}

Resource :: enum {
  Money,
  Pips,
}

Inventory :: struct {
  resources: [Resource]u64,
}

