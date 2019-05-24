
# task\_series

Utility plan to intelligently run a series of tasks and report back on the outcome.

#### Table of Contents

1. [Description](#description)
2. [Usage](#usage)

## Description

This module provides a Bolt plan which runs a series of tasks on specified targets. After each individual task completes, targets which did not complete that task successfully are set aside, and the next task in the series is run only on those targets on which the task succeeded. At the end, a summary of the series result is presented, along with the ResultSets for each step in the task series.

The summary will show which targets succeeded, as well as which targets failed and at which step.

## Usage

Example usage:

```puppet
plan task_series::test (
  TargetSpec $nodes = ['ssh://faketarget', 'local://willfailtest', 'local://1', 'local://2'],
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
```

Example return value:

```json
{
  "errored at step 0: validate connection": [
    "ssh://faketarget"
  ],
  "errored at step 1: task_series::test": [
    "local://willfailtest"
  ],
  "succeeded": [
    "local://1",
    "local://2",
    "local://3"
  ]
}
```
