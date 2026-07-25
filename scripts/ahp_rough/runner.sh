#!/bin/sh

script_root_path="$(dirname "$(readlink -f "$0")")"
repo_root_path="$(readlink -f "${script_root_path}/../..")"
simulation_out_folder=$1
scenario_name=$2
iteration_number=$3

scenario_out_folder="${simulation_out_folder}/${scenario_name}/ite${iteration_number}"
scenario_conf_file="${script_root_path}/config/${scenario_name}.properties"

mkdir -p "$scenario_out_folder"
java -classpath "${repo_root_path}/bin:${repo_root_path}/lib/cloudsim-7.0.0-alpha.jar:${repo_root_path}/lib/commons-math3-3.6.1.jar:${repo_root_path}/lib/colt.jar" edu.boun.edgecloudsim.applications.ahp_rough.MainApp "$scenario_conf_file" "$scenario_out_folder" "$iteration_number" > "${scenario_out_folder}.log"

if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ite${iteration_number} OK" >> "${simulation_out_folder}/${scenario_name}/progress.log"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ite${iteration_number} FAIL !!!" >> "${simulation_out_folder}/${scenario_name}/progress.log"
fi
