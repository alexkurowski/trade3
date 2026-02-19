package box

append :: proc {
  append_array,
  append_pool,
  append_queue,
}

clear :: proc {
  clear_array,
  clear_pool,
  clear_queue,
}

remove :: proc {
  remove_array,
  remove_pool,
}

is_full :: proc {
  is_pool_full,
  is_queue_full,
}

is_empty :: proc {
  is_pool_empty,
  is_queue_empty,
}
