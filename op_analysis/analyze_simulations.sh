#!/bin/bash

#-
#- 	   Osmotic Pressure Simulations
#- 		Analyze_runs
#- Last updated: Thu Jun 26 19:12:27 EDT 2014
#-
## Usage: ./analyze_simulations [options]
##	
##	-h	Show help options.
##	-v	Print version info.
##
## RECOMMENDED: Run this script in a separate subdirectory
##
## DEPENDENCIES: call_calc_op.sh and graph_calc_op.py.
##
## This script is recommended to run in a subdirectory at the same level as where the simulations were ran.
## The script will distribute a copy of computation.sh and calc_op.py to each subdirectory.
## calc_op.py is a dependency of computation.sh.
## Thus computation will calculate the osmotic pressure among some other observables of interest.
## The output is both on screen and in predetermined dat files.
## During the last step all dat files will be copied to the present directory,
## and a new file will be created to sumarize all the measurements for each concentration ran.
##
## After this script is ran, do CALL_PLOT.SH which will sumarize all the significant data in a new dat file.
## 

help=$(grep "^#-" "${BASH_SOURCE[0]}" | cut -c 4-)
opt_h()
{
        echo "$help"
}
while getopts "hv" opt; do
        eval "opt_$opt"
        exit
done

host=$(hostname)
# Determine the host
set -- "$host"
IFS="."; declare -a array=($*)
echo "${array[@]}"
flag="${array[1]}"
IFS=" "

case "$flag" in
        "stampede")
                module load python/2.7.9
                files=/scratch/03561/alarcj/data_base_stampede/osmotic_pressure_analysis_july12
                partition=normal
                echo "Running on sampede.tacc.xsede.org"
                ;;
        "sdsc")
                module load python
                module load scipy
                cluster=comet
                files=/oasis/scratch/comet/alarcj/temp_project/AMINO/data/op_analysis
                partition=compute
                echo "Running on comet.sdsc.xsede.org"
                ;;
        "terra" | "gaia")
                files=/data/disk02/alarcj/data_base_stampede/osmotic_pressure_run_july12
                echo "Running on ${cluster}"
                ;;
        *)
                echo "Unkown option."
                exit
esac


# Loops through the directories running the osmotic pressure calculation
pushd .
cd ../
for i in 5 15 30 45; do
	for j in {1..5}; do
		cd ${i}nmg_${j}run
		pwd
		cp -r ${files}/. .
		./call_calc_op.sh $i 	
		cd ../
	done
done

popd
# For each concentration it copies the output from computation.sh and appends all the measurements to a new file op_{concentration}.dat 
# op_{concentration}.dat will be used for further analysis
for i in 5 15 30 45;
do
	echo "#m 	        M  	       pi_ideal 	  pi_calc(mean +/- sd)" > op_${i}nmg.dat

        for j in 1 2 3 4 5; do 
        	tail --lines=-1 ../${i}nmg_${j}run/calculated_osmotic_Pressure.dat >> op_${i}nmg.dat
        
        done
done

pushd .
cd ../

popd

echo "#m                M              pi_ideal           pi_calc(mean +/- sd)" > statistics.dat

for i in 5 15 30 45;
do
	cp -r ${files}/stat.py .
        python stat.py op_${i}nmg.dat
done

