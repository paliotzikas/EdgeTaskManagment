# Scenario Comparison

| Scenario | Mode | Iterations | Completed | Offloaded | Proactive triggers | Reactive triggers | Deadline miss rate | Queue imbalance |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| default_config | PROACTIVE | 50 | 455.92 +/- 3.46 | 633.54 +/- 4.99 | 59.70 +/- 0.79 | 6.18 +/- 0.66 | 87.32% +/- 0.36% | 1447.48 +/- 14.67 |
| fifo_offloading | REACTIVE | 50 | 456.90 +/- 3.38 | 218.18 +/- 8.02 | 0.00 +/- 0.00 | 44.06 +/- 1.64 | 87.05% +/- 0.39% | 1837.28 +/- 15.40 |
| no_offloading | REACTIVE | 50 | 455.32 +/- 3.72 | 0.00 +/- 0.00 | 0.00 +/- 0.00 | 0.00 +/- 0.00 | 87.33% +/- 0.43% | 1923.60 +/- 16.42 |
| random_offloading | REACTIVE | 50 | 455.40 +/- 3.70 | 210.48 +/- 7.38 | 0.00 +/- 0.00 | 42.52 +/- 1.51 | 87.26% +/- 0.42% | 1843.98 +/- 16.92 |

Values are reported as mean +/- 95% confidence interval across iterations.
Use this table to compare the REACTIVE reference against the proposed PROACTIVE mode.
