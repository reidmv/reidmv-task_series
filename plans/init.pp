# Intended to allow this to work:
#
#     $series_results = run_plan('task_series',
#       nodes => $targets,
#       tasks => [
#         [ 'util::linux_patching',
#             foo => bar,
#             boo => baz,
#         ],
#         [ 'util::reboot',
#             blort => zlot,
#         ],
#         [ 'util::validate',
#             arg => val,
#         ],
#       ])
#
# And return a Hash that looks like:
#
#     {
#       "result_sets" => [
#         ResultSet,
#         ResultSet,
#         ResultSet,
#         ResultSet,
#       ],
#       "summary" => {
#         "errored at step 2: task::name": [
#           Target.name,
#           Target.name,
#         ],
#         "succeeded": [
#           Target.name,
#         ],
#       },
#     }
#
plan task_series (
  TargetSpec  $nodes,
  Array[Tuple[String, Hash[String, Any], 2, 2]] $tasks,
) {
  $targets = get_targets($nodes)

  # Filter out targets not currently reachable
  $connection_results = wait_until_available($targets,
    wait_time     => 0,
    _catch_errors => true,
  )

  $task_results = $tasks.reduce([$connection_results]) |$results, $task| {
    $task_array = Array($task)
    notice($task_array)
    $results << run_task($task_array[0], $results[-1].ok_set.targets,
      $task_array[1] + { _catch_errors => true },
    )
  }[1,-1] # omit the connection results from $task_results

  $indexed_labeled_results = [
    [0, 'validate connection', $connection_results]
  ] + $task_results.map |$index, $result| {
    [$index + 1, $tasks[$index][0], $result]
  }

  return({
    'connection_results' => $connection_results,
    'task_results'       => $task_results,
    'summary'            => task_series::summarize($indexed_labeled_results),
  })
}
