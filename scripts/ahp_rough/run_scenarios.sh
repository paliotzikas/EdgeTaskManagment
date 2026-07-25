#!/bin/bash
if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
	echo "Missing arguments! Please provide number of parallel processes and number of iterations."
	echo "Usage: '$0 4 10 [simulation_list_file]'"
	exit 1
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
	echo "$1 is not an integer! Please provide number of parallel processes."
	exit 1
fi

if ! [[ $2 =~ $re ]] ; then
	echo "$2 is not an integer! Please provide number of iterations."
	exit 1
fi

script_root_path="$(dirname "$(readlink -f "$0")")"
cd "$script_root_path" || exit 1
root_out_folder="output"
num_of_processes=$1
iterationNumber=$2
simulation_list_file=${3:-simulation.list}
process_counter=0

date=$(date '+%d-%m-%Y_%H-%M')
simulation_out_folder="${root_out_folder}/${date}"
mkdir -p "$simulation_out_folder"

if [ ! -f "$simulation_list_file" ]; then
	echo "Cannot find simulation list file: $simulation_list_file"
	exit 1
fi

simulations=$(cat "$simulation_list_file")
rm -rf "${simulation_out_folder}"/tmp_runner*

for scenario_name in $simulations
do
	mkdir -p "${simulation_out_folder}/${scenario_name}"
	echo "$(date '+%Y-%m-%d %H:%M:%S') - STARTED" > "${simulation_out_folder}/${scenario_name}/progress.log"

	for (( i=1; i<=$iterationNumber; i++ ))
	do
		process_id=$(($process_counter % $num_of_processes))
		process_counter=$(($process_counter + 1))
		printf '"./runner.sh" "%s" "%s" "%s"\n' "$simulation_out_folder" "$scenario_name" "${i}" >> "${simulation_out_folder}/tmp_runner${process_id}.sh"
	done
done

for (( i=0; i<$num_of_processes; i++ ))
do
	chmod +x "${simulation_out_folder}/tmp_runner${i}.sh"
	"./${simulation_out_folder}/tmp_runner${i}.sh" &
	pid=$!
	echo "$pid" >> "${simulation_out_folder}/simulation_pids.txt"
done

echo "###############################################################"
echo "                  SIMULATIONS ARE STARTED!"
echo "###############################################################"
echo "Simulation ID: ${date}"
echo "tail -f output/${date}/default_config/progress.log"
echo "###############################################################"
