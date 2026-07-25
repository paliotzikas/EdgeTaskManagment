# Scenario Comparison

| Scenario | Policy | Iterations | Generated | Completed | Offloaded | Completion rate | Offload rate | Offloads/delay |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| default_config | AHP_ROUGH | 50 | 6778.18 +/- 25.96 | 454.74 +/- 3.94 | 467.20 +/- 17.35 | 6.71% +/- 0.07% | 6.89% +/- 0.25% | 4.07 +/- 0.12 |
| fifo_offloading | FIFO | 50 | 6778.18 +/- 25.96 | 457.22 +/- 3.32 | 217.68 +/- 8.30 | 6.75% +/- 0.06% | 3.21% +/- 0.12% | 1.88 +/- 0.06 |
| no_offloading | NONE | 50 | 6778.18 +/- 25.96 | 455.32 +/- 3.72 | 0.00 +/- 0.00 | 6.72% +/- 0.06% | 0.00% +/- 0.00% | 0.00 +/- 0.00 |
| random_offloading | RANDOM | 50 | 6778.18 +/- 25.96 | 455.68 +/- 3.64 | 213.48 +/- 7.94 | 6.72% +/- 0.06% | 3.15% +/- 0.12% | 1.87 +/- 0.06 |

Values are reported as mean +/- 95% confidence interval across iterations.
Use this table to compare the proposed AHP_ROUGH method against NONE, FIFO, and RANDOM baselines.
