#!/bin/bash

file1=$1
file2=$2
output_file=$3
head --lines=-1 $file1 > $output_file
tail --lines=+3 $file2 >> $output_file
tot=$((`wc -l $output_file | awk '{print $1}'` -3));
sed -i "2c\ $tot" $output_file
sed -i "`echo "${tot} + 3" | bc -l`s/.*/   3.90000   3.90000   7.80000/" $output_file

OW=$(grep OW $output_file |wc -l)
#var=`tail -1 topol.top`
sed -i "/SOL/c\SOL               ${OW}" topol.top

exit

