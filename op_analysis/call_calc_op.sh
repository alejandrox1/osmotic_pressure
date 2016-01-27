#!/bin/bash

Nmg=$1

rm calculated_osmotic_Pressure.dat 
# Files needed
simulation_file=simul_equil.gro
if [ -e "$simulation_file" ]; then
	central_chamber=central_shifted.gro
	output_file=calculated_osmotic_Pressure.dat
	pullf=pullf.xvg
	skip=1000 		 ## want to  Skip first 200 ps
	#graph=forces_${Nmg}.pdf

	# Setting parameters
	echo "m                 M               ideal_op                calculated_OP"> $output_file
	L=`tail -1 $simulation_file | awk '{print $1}'`
	Nwat=`grep OW $central_chamber | wc -l`

	# Run analysis
	python graph_calc_op.py $Nmg $L $Nwat $output_file $pullf $skip #$graph
fi
