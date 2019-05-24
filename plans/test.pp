plan task_series::test (
  TargetSpec $nodes = ['ssh://foo', 'local://1', 'local://2', 'local://3'],
) {
  $targets = get_targets($nodes)

  $series_result = run_plan('task_series',
    nodes => $targets,
    tasks => [
      [ 'task_series::test',
          exit_code => 0,
      ],
      [ 'task_series::test',
          exit_code => 0,
      ],
      [ 'task_series::test',
          exit_code => 0,
      ],
    ],
  )

  return($series_result[summary])
}
