#!/usr/bin/env python3
import csv
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path


def mean(values):
    return sum(values) / len(values) if values else 0.0


def stdev(values):
    return statistics.stdev(values) if len(values) > 1 else 0.0


def t_critical_95(sample_size):
    df = sample_size - 1
    table = {
        1: 12.706, 2: 4.303, 3: 3.182, 4: 2.776, 5: 2.571,
        6: 2.447, 7: 2.365, 8: 2.306, 9: 2.262, 10: 2.228,
        11: 2.201, 12: 2.179, 13: 2.160, 14: 2.145, 15: 2.131,
        16: 2.120, 17: 2.110, 18: 2.101, 19: 2.093, 20: 2.086,
        21: 2.080, 22: 2.074, 23: 2.069, 24: 2.064, 25: 2.060,
        26: 2.056, 27: 2.052, 28: 2.048, 29: 2.045, 30: 2.042,
    }
    if df <= 0:
        return 0.0
    if df in table:
        return table[df]
    return 1.96


def ci95_half_width(values):
    if len(values) <= 1:
        return 0.0
    return t_critical_95(len(values)) * stdev(values) / (len(values) ** 0.5)


def read_summary(path):
    values = {}
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            if "=" not in line:
                continue
            key, value = line.strip().split("=", 1)
            try:
                values[key] = float(value)
            except ValueError:
                values[key] = value
    return values


def read_task_events(path):
    with open(path, newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def collect_iteration_metrics(scenario_dir):
    rows = []
    iteration_dirs = sorted(
        [p for p in scenario_dir.iterdir() if p.is_dir() and re.match(r"ite\d+$", p.name)],
        key=lambda p: int(p.name[3:]),
    )
    if not iteration_dirs and (scenario_dir / "summary.txt").exists():
        iteration_dirs = [scenario_dir]

    for iteration_dir in iteration_dirs:
        iteration = int(iteration_dir.name[3:]) if re.match(r"ite\d+$", iteration_dir.name) else 1
        summary = read_summary(iteration_dir / "summary.txt")
        task_events = read_task_events(iteration_dir / "task_events.csv")
        offloaded = [row for row in task_events if row["event"] == "OFFLOADED"]
        started = [row for row in task_events if row["event"] == "STARTED"]

        generated = int(summary["generated_tasks"])
        completed = int(summary["completed_tasks"])
        delayed = int(summary["delayed_tasks"])
        offloaded_count = int(summary["offloaded_tasks"])
        policy = summary.get("offloading_policy", scenario_dir.name)
        decision_mode = summary.get("decision_mode", "REACTIVE")
        destination_policy = summary.get("offload_destination_policy", "DROP")
        threshold_mode = summary.get("threshold_mode", "FIXED")
        threshold_multiplier = float(summary.get("threshold_multiplier", 1.0))
        total_waiting = int(summary.get("total_waiting_tasks", 0))
        queue_imbalance = int(summary.get("queue_imbalance", 0))
        received_offloaded = int(summary.get("received_offloaded_tasks", 0))
        completed_offloaded = int(summary.get("completed_offloaded_tasks", 0))
        proactive_triggers = int(summary.get("proactive_trigger_events", 0))
        reactive_triggers = int(summary.get("reactive_trigger_events", 0))
        deadline_misses = int(summary.get("completed_deadline_misses", 0))
        max_offloads_per_event = float(summary.get("max_offloads_per_event", 0))
        offload_fraction = float(summary.get("offload_fraction", 0))
        high_arrival_rate_threshold = float(summary.get("high_arrival_rate_threshold", 0))

        rough_scores = [float(row["rough_score"]) for row in offloaded] if offloaded else []
        actual_execution = [
            float(row["base_execution_time"]) * float(row["delay_multiplier"])
            for row in started
        ]

        rows.append({
            "scenario": scenario_dir.name,
            "policy": policy,
            "decision_mode": decision_mode,
            "destination_policy": destination_policy,
            "threshold_mode": threshold_mode,
            "iteration": iteration,
            "generated": generated,
            "completed": completed,
            "delayed": delayed,
            "offloaded": offloaded_count,
            "received_offloaded": received_offloaded,
            "completed_offloaded": completed_offloaded,
            "proactive_trigger_events": proactive_triggers,
            "reactive_trigger_events": reactive_triggers,
            "completed_deadline_misses": deadline_misses,
            "total_waiting_tasks": total_waiting,
            "queue_imbalance": queue_imbalance,
            "max_offloads_per_event": max_offloads_per_event,
            "offload_fraction": offload_fraction,
            "high_arrival_rate_threshold": high_arrival_rate_threshold,
            "threshold_multiplier": threshold_multiplier,
            "completion_rate": completed / generated if generated else 0.0,
            "offload_rate": offloaded_count / generated if generated else 0.0,
            "offload_per_delayed": offloaded_count / delayed if delayed else 0.0,
            "deadline_miss_rate": deadline_misses / completed if completed else 0.0,
            "mean_rough_score": mean(rough_scores),
            "mean_actual_execution_time": mean(actual_execution),
        })
    return rows


def summarize(rows):
    grouped = defaultdict(list)
    for row in rows:
        grouped[row["scenario"]].append(row)

    metrics = [
        "generated",
        "completed",
        "delayed",
        "offloaded",
        "received_offloaded",
        "completed_offloaded",
        "proactive_trigger_events",
        "reactive_trigger_events",
        "completed_deadline_misses",
        "total_waiting_tasks",
        "queue_imbalance",
        "max_offloads_per_event",
        "offload_fraction",
        "high_arrival_rate_threshold",
        "threshold_multiplier",
        "completion_rate",
        "offload_rate",
        "offload_per_delayed",
        "deadline_miss_rate",
        "mean_rough_score",
        "mean_actual_execution_time",
    ]

    summary_rows = []
    for scenario, scenario_rows in sorted(grouped.items()):
        policy = scenario_rows[0]["policy"]
        decision_mode = scenario_rows[0]["decision_mode"]
        destination_policy = scenario_rows[0]["destination_policy"]
        threshold_mode = scenario_rows[0]["threshold_mode"]
        result = {
            "scenario": scenario,
            "policy": policy,
            "decision_mode": decision_mode,
            "destination_policy": destination_policy,
            "threshold_mode": threshold_mode,
            "iterations": len(scenario_rows),
        }
        for metric in metrics:
            values = [float(row[metric]) for row in scenario_rows]
            result[f"{metric}_mean"] = mean(values)
            result[f"{metric}_std"] = stdev(values)
            result[f"{metric}_sem"] = stdev(values) / (len(values) ** 0.5) if values else 0.0
            result[f"{metric}_ci95"] = ci95_half_width(values)
        summary_rows.append(result)
    return summary_rows


def write_csv(path, rows):
    if not rows:
        return
    with open(path, "w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def write_markdown(path, summary_rows):
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("# Scenario Comparison\n\n")
        handle.write("| Scenario | Mode | Iterations | Completed | Offloaded | Proactive triggers | Reactive triggers | Deadline miss rate | Queue imbalance |\n")
        handle.write("|---|---|---:|---:|---:|---:|---:|---:|---:|\n")
        for row in summary_rows:
            handle.write(
                f"| {row['scenario']} | {row['decision_mode']} | {row['iterations']} "
                f"| {row['completed_mean']:.2f} +/- {row['completed_ci95']:.2f} "
                f"| {row['offloaded_mean']:.2f} +/- {row['offloaded_ci95']:.2f} "
                f"| {row['proactive_trigger_events_mean']:.2f} +/- {row['proactive_trigger_events_ci95']:.2f} "
                f"| {row['reactive_trigger_events_mean']:.2f} +/- {row['reactive_trigger_events_ci95']:.2f} "
                f"| {100 * row['deadline_miss_rate_mean']:.2f}% +/- {100 * row['deadline_miss_rate_ci95']:.2f}% "
                f"| {row['queue_imbalance_mean']:.2f} +/- {row['queue_imbalance_ci95']:.2f} |\n"
            )
        handle.write("\n")
        handle.write("Values are reported as mean +/- 95% confidence interval across iterations.\n")
        handle.write("Use this table to compare the REACTIVE reference against the proposed PROACTIVE mode.\n")


def main():
    if len(sys.argv) != 2:
        print("Usage: python analyze_run.py <output/simulation_id>")
        return 1

    run_dir = Path(sys.argv[1]).resolve()
    if not run_dir.exists():
        print(f"Run folder does not exist: {run_dir}")
        return 1

    all_rows = []
    for scenario_dir in sorted([p for p in run_dir.iterdir() if p.is_dir()]):
        all_rows.extend(collect_iteration_metrics(scenario_dir))

    if not all_rows:
        print(f"No iteration data found under: {run_dir}")
        return 1

    analysis_dir = run_dir / "comparison"
    analysis_dir.mkdir(exist_ok=True)
    summary_rows = summarize(all_rows)
    write_csv(analysis_dir / "iteration_comparison.csv", all_rows)
    write_csv(analysis_dir / "scenario_summary.csv", summary_rows)
    write_markdown(analysis_dir / "scenario_comparison.md", summary_rows)
    print(f"Wrote comparison files to: {analysis_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
