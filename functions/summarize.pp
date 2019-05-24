function task_series::summarize(
  Array[Tuple[Integer, String, ResultSet]] $indexed_labeled_results,
) {
  $summary_struct = $indexed_labeled_results.reduce([]) |$array, $tup| {
    $array << ["errored at step ${tup[0]}: ${tup[1]}", $tup[2].error_set.names]
  } << ['succeeded', $indexed_labeled_results[-1][2].ok_set.names]

  $summary = Hash($summary_struct).filter |$key, $value| { ! $value.empty }

  return($summary)
}
