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

  # Run all tasks in the series, one after the other, collecting each resultset
  # in an array. When running each task, only run it on the targets that
  # successfully completed the previous task.
  $task_results = $tasks.reduce([$connection_results]) |$memo, $tuple| {
    $title  = $tuple[0]
    $params = $tuple[1]

    # Run the task and add its results to memo. The targets are the nodes which
    # successfully completed the previous task.
    $memo << run_task($title, $memo[-1].ok_set.targets,
      $params + { _catch_errors => true },
    )

  }[1,-1] # omit the connection results from $task_results

  # Build an array of [INDEX, NAME, RESULTS] tuples. This will be passed into
  # the task_series::summarize function later to produce a readable summary of
  # which nodes succeeded, which nodes failed, and for the failed nodes, which
  # step they failed at.
  $index_label_results = [
    [0, 'validate connection', $connection_results]
  ] + $task_results.map |$index, $result| {
    [$index + 1, $tasks[$index][0], $result]
  }

  return({
    'connection_results' => $connection_results,
    'task_results'       => $task_results,
    'summary'            => task_series::summarize($index_label_results),
  })
}
