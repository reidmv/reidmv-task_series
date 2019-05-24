function task_series::summarize(
  Array[ResultSet] $results,
) {
  $summary_struct = $results.map |$index, $set| {
    [$index, $set]
  }.reduce([]) |$array, $tup| {
    $array << ["errored at step ${tup[0] + 1}: ${tup[1]}", $tup[1].error_set.names]
  } << ['succeeded', $results[-1].ok_set.names]

  $summary = Hash($summary_struct).filter |$key, $value| { ! $value.empty }

  return($summary)
}
