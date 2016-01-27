#!/bin/bash
#-
#-	Comment the [ defaults ] directive on ffoplsaa.itp
#-	before trying to scale the interactions.
#-
#-	/home/alarcj/exe/gromacs-4.0.7_flatbottom/share/top/ffoplsaa.itp


flj=$1		
fqq=$2
fudgeLJ=0.5 	# OPLSAA
fudgeQQ=0.5	# OPLSAA

sed -i "8i [ defaults ]" topol.top
sed -i "9i ; nbfunc        comb-rule       gen-pairs       fudgeLJ fudgeQQ" topol.top
sed -i "10i 1               3               yes             ${flj:-$fudgeLJ}     ${fqq:-$fudgeQQ}" topol.top

touch check_params.txt
echo $flj >> check_params.txt
echo $fqq >> check_params.txt
