#!/bin/bash

module load intel
module load impi
gmxdir=/home1/03561/alarcj/gromacs/exe/gromacs-4.0.7_flatbottom/exec/bin

INPUTmdp=$1
minimizedGRO=$2
L=$3
Nmg=$4

FC=350.0  ## in kJ/mol/nm^2 for the equation U=0.5*FC*d^2                      JUNE 17, 2014: CHNAGED FROM 3500.0 FOR GLYCINE_OPLS_3P/GLY-KTRIAL RUN
FlatHalfWidth=`echo "scale=2;$L/2" | bc -l`  ## in nm, the distance the particle is allowed to move away from z=0 with no penalty

{
cat ${INPUTmdp} 
echo "pull = umbrella"
echo "pull-geometry = distance"
echo "pull-dim = N N Y"
echo "pull-start = no"
echo "pull-nstfout = 500"
echo "pull-nstxout = 500"

echo "; do not define pull-group0 so the reference position will be 0,0,0"
echo "pull-ngroups=${Nmg}"
for((i=1; i<=${Nmg};i++)); do
  echo "pull-group${i} = r_${i}"
  echo "pull-init${i} = 0.0"
  echo "pull-k${i} = ${FC}"
  echo "pull-flat${i} = ${FlatHalfWidth}"
done
} > this.mdp

{
for((i=1; i<=$Nmg;i++)); do
  echo r${i}
done
echo q
} > my.inp

cat my.inp | $gmxdir/make_ndx -f ${minimizedGRO} -o this.ndx
