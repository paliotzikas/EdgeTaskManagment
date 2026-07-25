#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "Missing simulation id."
	echo "Usage: '$0 13-07-2026_10-30'"
	exit 1
fi

script_root_path="$(dirname "$(readlink -f "$0")")"
pid_file="${script_root_path}/output/$1/simulation_pids.txt"

if [ ! -f "$pid_file" ]; then
	echo "Cannot find pid file: $pid_file"
	exit 1
fi

while read pid; do
	kill -TERM "$pid" 2>/dev/null
done < "$pid_file"
