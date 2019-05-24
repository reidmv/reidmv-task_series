# Intended to allow this to work:
#
# $series_results = run_plan('task_series',
#   nodes => $targets,
#   tasks => [
#     [ 'util::linux_patching',
#         foo => bar,
#         boo => baz,
#     ],
#     [ 'util::reboot',
#         blort => zlot,
#     ],
#     [ 'util::validate',
#         arg => val,
#     ],
#   ])
#
# And return a Hash that looks like:
#
# {
#   "results" => [
#     ResultSet,
#     ResultSet,
#     ResultSet,
#   ],
#   "summary" => {
#     "errored-at-step-2": [
#       "local://1",
#       "local://2",
#     ],
#     "succeeded": [
#       "local://3",
#     ],
#   },
# }
#
plan task_series (
  TargetSpec  $nodes,
  Array[Tuple[String, Hash[String, Any], 2, 2]] $tasks,
) {
  $targets = get_targets($nodes)

  # Short-circuit the plan if there are no targets
  # TODO: is this even necessary?
  if $targets.empty { return({'results' => ResultSet([]), 'summary' => {}}) }

  # Filter out targets not currently reachable
  $connection_results = wait_until_available($targets,
    wait_time     => 0,
    _catch_errors => true,
  )

  $results = $tasks.reduce([$connection_results]) |$results_array, $task| {
    $task_array = Array($task)
    notice($task_array)
    $results_array << run_task($task_array[0], $results_array[-1].ok_set.targets,
      $task_array[1] + { _catch_errors => true },
    )
  }

  return({
    'results' => $results,
    'summary' => task_series::summarize($results),
  })
}
