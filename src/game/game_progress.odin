#+private
package game

Progress :: struct {
  inventory: Inventory,
}

Resource :: enum {
  Money,
  Pips,
}

Inventory :: struct {
  resources: [Resource]u64,
}

