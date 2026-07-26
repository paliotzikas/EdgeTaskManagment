# Scenario Comparison

| Scenario | Mode | Iterations | Completed | Offloaded | Proactive triggers | Reactive triggers | Deadline miss rate | Queue imbalance |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| selector_ablation_ahp_rough | PROACTIVE | 50 | 455.92 +/- 3.46 | 633.54 +/- 4.99 | 59.70 +/- 0.79 | 6.18 +/- 0.66 | 87.32% +/- 0.36% | 1447.48 +/- 14.67 |
| selector_ablation_fifo | PROACTIVE | 50 | 455.12 +/- 3.76 | 637.24 +/- 4.20 | 59.62 +/- 0.81 | 6.44 +/- 0.71 | 86.90% +/- 0.38% | 1448.12 +/- 15.27 |
| selector_ablation_none | PROACTIVE | 50 | 455.32 +/- 3.72 | 0.00 +/- 0.00 | 0.00 +/- 0.00 | 0.00 +/- 0.00 | 87.33% +/- 0.43% | 1923.60 +/- 16.42 |
| selector_ablation_random | PROACTIVE | 50 | 455.02 +/- 3.72 | 635.64 +/- 4.48 | 60.42 +/- 0.85 | 5.48 +/- 0.72 | 87.69% +/- 0.37% | 1448.48 +/- 15.29 |

Values are reported as mean +/- 95% confidence interval across iterations.
Use this table to compare the REACTIVE reference against the proposed PROACTIVE mode.
