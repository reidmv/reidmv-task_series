function task_series::summarize(
  Array[Tuple[Integer, String, ResultSet]] $index_label_results,
) {
  # Build an array consisting of one entry per step, with the list of nodes
  # that failed at that step. Finalize it by adding, at the end, the list of
  # nodes that did not fail at any step (the nodes that succeeded).
  $summary_struct = $index_label_results.reduce([]) |$memo, $tuple| {
    $memo << ["errored at step ${tuple[0]}: ${tuple[1]}", $tuple[2].error_set.names]
  } << ['succeeded', $index_label_results[-1][2].ok_set.names]

  # Remove from the array any steps at which no nodes failed. Turn the filtered
  # summary into a hash.
  $summary = Hash($summary_struct).filter |$key, $value| { ! $value.empty }

  return($summary)
}
