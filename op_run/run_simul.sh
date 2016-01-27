#!/bin/bash

#SBATCH --exclusive           # Individual nodes
#SBATCH -t 2-0                # Run time (hh:mm:ss)
#SBATCH -J PRESSURE
#SBATCH -o slurm.%j.out

cluster=$1
n=$2

case "$cluster" in
        "stampede")
                module load intel
                module load impi
                gmxdir=/home1/03561/alarcj/gromacs/exe/gromacs-4.0.7_flatbottom/exec/bin
		ibrun=ibrun
                ;;
        "comet")
                module load intel
                module load openmpi_ib/1.8.4
                gmxdir=/home/alarcj/gromacs_stampede/exe/gromacs-4.0.7_flatbottom/exec/bin
                ibrun=ibrun
		;;
        "terra"|"gaia")
                module load mpi/openmpi
                gmxdir=/home/alarcj/exe/gromacs-4.0.7_flatbottom/exec/bin
                ibrun=mpirun
		;;
        *)
                echo "Unkown option."
                exit
esac


# Production run
$gmxdir/grompp -f this.mdp -c nvt.gro -p topol.top -o simul_equil.tpr -n this.ndx -maxwarn 1
${ibrun} -np ${n} $gmxdir/mdrun_mpi -v -deffnm simul_equil -px pullx.xvg -pf pullf.xvg -append -cpi simul_equil.cpt -cpo simul_equil.cpt -maxh 47.95

echo -e "0\n" | $gmxdir/trjconv -f simul_equil.trr -s simul_equil.tpr -pbc mol -o simul_equil.xtc

rm \#*
rm *trr
