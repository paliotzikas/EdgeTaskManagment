#!/bin/sh
script_root_path="$(dirname "$(readlink -f "$0")")"
repo_root_path="$(readlink -f "${script_root_path}/../..")"

rm -rf "${repo_root_path}/bin"
mkdir "${repo_root_path}/bin"
javac -classpath "${repo_root_path}/lib/cloudsim-7.0.0-alpha.jar:${repo_root_path}/lib/commons-math3-3.6.1.jar:${repo_root_path}/lib/colt.jar" -sourcepath "${repo_root_path}/src" "${repo_root_path}/src/edu/boun/edgecloudsim/applications/ahp_rough/MainApp.java" -d "${repo_root_path}/bin"
