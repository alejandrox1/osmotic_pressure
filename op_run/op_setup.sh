#!/bin/bash

#-
#-	             :-)   op_setup.sh   (-:
#-     		Osmotic Pressure Simulations
#-     		Made on: Sun Jul 12 21:35:08 EDT 2015
#-		Updated: Wed Jan 27 11:21:46 EST 2016
#-			updated information on script
#-     		Previous Updated: Mon Sep 14 10:56:18 EDT 2015  
#-		Previous update: Fri Aug 28 17:58:18 EDT 2015 
#-
#-
#-      	Usage: ./op_setup.sh <FILE NAME> 
#-			File should include: 			
#-			<NODES > <CORES> <COSOLVENT> <WATER> <FUDGE Q> <FUDGE LJ>
#-
#-      	-h      Show help options.
#-
#- Look at the last part of the script for running a given concentration of cosolvents.
#-
#- op_setup.sh will determine upon previous configurations the locations of all
#- gromacs executables needed to run the simulations along with all files needed
#- to set up the system.
#- 
#- All parameter files (mdp, pdb, etc.) are found on a predetermined location
#- different for all cluster with the common name of "file-database".
#-
#- In order to run the set of osmotic pressure simulation it is necessary to specify 
#- the cluster on which the simulations will be run (e.g. comet, stampede) along with 
#- the solution aditive to be used and the water model for the simulation.
#-
#- OPTIONS:
#-	N = number of nodes to be used.
#-	residue = structure.
#-	water = water model.
#-
#- Gromacs versions being used: gromacs-4.0.7	
#- This gromacs version was modified by Dr. Christopher Neale to use a flat bottom 
#- potential, which is needed for the calculation (Lou and Roux DOI: 10.1021/jz900079w).
#-
#- NOTES ON PERFORMANCE:
#-	comet has 24 nodes per core.
#-	stampede has 16 nodes per core.
#-	terra has 8 nodes per core.
#-	gaia has 2 nodes per core.
#-
##
## Number of Nodes
## Number of cores per node
## Structure to be used
## Water model
## Coulomb scaling parameter
## LJ scaling parameters
##
opt_h()
{
	echo "$(grep "^#-" "${BASH_SOURCE[0]}" | cut -c 4-)"
	echo "$(grep "^##" "${BASH_SOURCE[0]}" | cut -c 4-)"
}
while getopts "hv" opt; do
        eval "opt_$opt"
	exit
done


# INPUT PARAMETERS
host=$(hostname)
args=()
i=0
while read line 
do
	args[i]=$line 
	i=$(($i + 1))
done < $1
N="${args[0]}"
n="${args[1]}"
residue="${args[2]}"
water="${args[3]}"
ff_qq="${args[4]}"
ff_lj="${args[5]}"

# Determine the host
set -- "$host"
IFS="."; declare -a array=($*)
echo "${array[@]}"
flag="${array[1]}"

case "$flag" in
	"stampede")
		cluster="$flag"
		files=/scratch/03561/alarcj/data/op_run 
		partition=normal
		echo "Running on sampede.tacc.xsede.org"
		;;
	"sdsc")
		cluster=comet
		files=/oasis/scratch/comet/alarcj/temp_project/AMINO/data/op_run  
		partition=compute
		echo "Running on comet.sdsc.xsede.org"
		;;
	"phys")
                cluster="${array[0]}"
		if [ "$cluster" == "terra" ]; then
	                files=/data/disk04/alarcj/data/op_run
	                echo "Running on terra.phys.rpi.edu"
		elif [ "$cluster" == "gaia" ]; then
			files=/data/disk04/alarcj/data/op_run
			echo "Running on gaia.phys.rpi.edu"
		fi
		;;
	*)
		echo "Unkown option."
		exit
esac

for i in 1; do
        for j in 1; do
		cp -r ${files} ${i}nmg_${j}run
		cd ${i}nmg_${j}run
		
		case  "$cluster" in
		"comet")
			sbatch -A TG-MCB130178 --export=NONE --no-requeue -p $partition -N $N -n $n run_op.sh $cluster $n $residue $water $i $ff_lj $ff_qq  > submit.txt
			id=`awk 'END {print $NF}' submit.txt`
			sbatch -A TG-MCB130178 --dependency=afterok:${id} --export=NONE --no-requeue -p $partition -N $N -n $n run_simul.sh $cluster $n
			;;
		"stampede")
			sbatch -A TG-MCB130178 -p $partition -N $N -n $n run_op.sh $cluster $n $residue $water $i $ff_lj $ff_qq > submit.txt
                        id=`awk 'END {print $NF}' submit.txt`
                        sbatch -A TG-MCB130178 --dependency=afterok:${id} -p $partition -N $N -n $n run_simul.sh $cluster $n
			;;
		"terra" | "gaia")
			sbatch -N $N -n $n run_op.sh $cluster $n $residue $water $i $ff_lj $ff_qq > submit.txt
                        id=`awk 'END {print $NF}' submit.txt`
                        sbatch --dependency=afterok:${id} -N $N -n $n run_simul.sh $cluster $n
			;;
		esac

		cd ../
	done
done


