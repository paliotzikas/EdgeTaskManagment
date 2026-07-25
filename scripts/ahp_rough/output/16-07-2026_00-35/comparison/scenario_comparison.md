# Scenario Comparison

| Scenario | Policy | Iterations | Generated | Completed | Offloaded | Completion rate | Offload rate | Offloads/delay |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| destination_drop | AHP_ROUGH | 20 | 6771.90 +/- 44.50 | 454.15 +/- 5.89 | 457.90 +/- 28.68 | 6.71% +/- 0.10% | 6.76% +/- 0.42% | 4.03 +/- 0.16 |
| destination_least_queue | AHP_ROUGH | 20 | 6771.90 +/- 44.50 | 453.35 +/- 6.82 | 456.50 +/- 31.16 | 6.70% +/- 0.11% | 6.74% +/- 0.46% | 4.04 +/- 0.22 |
| destination_min_estimated_delay | AHP_ROUGH | 20 | 6771.90 +/- 44.50 | 452.35 +/- 6.73 | 440.00 +/- 31.97 | 6.68% +/- 0.11% | 6.50% +/- 0.47% | 3.91 +/- 0.24 |

Values are reported as mean +/- 95% confidence interval across iterations.
Use this table to compare the proposed AHP_ROUGH method against NONE, FIFO, and RANDOM baselines.
