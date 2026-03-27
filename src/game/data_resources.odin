#+private
package game

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

