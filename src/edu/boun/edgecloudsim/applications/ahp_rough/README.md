# AHP + Rough Sets Queue Scenario

This application implements an application-level CloudSim simulation for N edge nodes.

For every node, task arrivals are sampled from a Poisson distribution with a node-specific
rate. Each task is a vector with priority, step count, complexity, deadline slack, and
execution-time fields. Every node executes one task at a time and keeps the rest in a
waiting queue.

When a running task is stochastically delayed and the observed arrival rate is high, the
node ranks waiting tasks with AHP weights and a rough-set-inspired lower/boundary
approximation. Selected tasks are removed from the local queue and logged as offloaded.
The current scenario intentionally does not model the destination node.

Output files:

- `task_events.csv`: task arrivals, execution starts, completions, and offload decisions.
- `node_state.csv`: observed arrival rates and queue sizes per node per tick.
- `summary.txt`: aggregate counters at the end of the simulation.

Supported `offloading_policy` values:

- `AHP_ROUGH`: proposed AHP + rough sets selection.
- `NONE`: no offloading baseline.
- `FIFO`: offload the oldest waiting tasks first.
- `RANDOM`: offload randomly selected waiting tasks.

Supported `offload_destination_policy` values:

- `DROP`: selected tasks leave the source queue and are not modeled further.
- `LEAST_QUEUE`: selected tasks are transferred to the node with the smallest waiting queue.

When `vary_seed_by_iteration=1`, the effective seed is derived from `random_seed`
and the iteration number. This makes iterations independent while keeping policies
comparable for the same iteration.
