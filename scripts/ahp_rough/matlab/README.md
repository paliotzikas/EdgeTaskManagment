# Matlab plots for AHP + Rough Sets

Run the simulation first:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\ahp_rough\compile.ps1
powershell -ExecutionPolicy Bypass -File scripts\ahp_rough\run_once.ps1
```

Then open Matlab in `scripts/ahp_rough/matlab` and run:

```matlab
plotAll()
```

For a batch output folder created by `run_scenarios.sh`, use:

```matlab
plotAll('../output/13-07-2026_10-30', 1)
```

The scripts generate PNG images in the run folder under `plots/`:

- `arrival_rate.png`
- `queue_size.png`
- `task_event_counts.png`
- `offload_scores.png`
- `execution_delay.png`

For scenario-level comparison plots, run `analyze_run.py` first and then:

```matlab
plotComparison('13-07-2026_19-06')
```

This writes PNG files under `output/<simulation_id>/comparison/plots`.

For `max_offloads_per_event` sensitivity runs:

```matlab
plotSensitivityMaxOffloads('13-07-2026_20-30')
```

This writes PNG files under `output/<simulation_id>/comparison/sensitivity_plots`.

For adaptive-threshold sensitivity runs:

```matlab
plotSensitivityAdaptiveThreshold('13-07-2026_21-00')
```

This writes PNG files under `output/<simulation_id>/comparison/adaptive_threshold_plots`.

For destination-policy comparison runs:

```matlab
plotDestinationComparison('15-07-2026_02-30')
```

This writes PNG files under `output/<simulation_id>/comparison/destination_plots`.
