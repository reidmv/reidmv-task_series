plan task_series::test (
  TargetSpec $nodes = ['local://1', 'local://2', 'local://3'],
) {
  $targets = get_targets($nodes)

  $series = run_plan('task_series',
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

  return($series)
}
