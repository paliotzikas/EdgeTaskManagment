# Scenario Comparison

| Scenario | Mode | Iterations | Completed | Offloaded | Proactive triggers | Reactive triggers | Deadline miss rate | Queue imbalance |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| proactive_ahp_rough | PROACTIVE | 50 | 455.92 +/- 3.46 | 633.54 +/- 4.99 | 59.70 +/- 0.79 | 6.18 +/- 0.66 | 87.32% +/- 0.36% | 1447.48 +/- 14.67 |
| reactive_ahp_rough | REACTIVE | 50 | 454.92 +/- 3.94 | 464.66 +/- 16.57 | 0.00 +/- 0.00 | 47.48 +/- 1.73 | 86.96% +/- 0.43% | 1620.04 +/- 21.69 |

Values are reported as mean +/- 95% confidence interval across iterations.
Use this table to compare the REACTIVE reference against the proposed PROACTIVE mode.
