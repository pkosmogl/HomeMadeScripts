#!/bin/bash

# In this script we run over all yoda files, in order to find
# suscpicious yoda files that contain badly weighted events.
# The sumw2 is huge for these yoda files and we want to pinpoint
# them and remove them, before merging them using the yodamerge command!

# Beware that you have to manualy tune the script, in order to search
# in the right line inside the yoda files but also to change the condition
# number that you compare to.

echo "==================================================="

for i in *.yoda*; do
	MYLINEdn=$(head -314 $i | tail -1 | awk '{print $4}')
	MYBINdn=$(printf %.10f $MYLINEdn)
	echo $MYBINdn

#	if (( "`echo "$MYBINdn >= 0.0000000001" | bc`" )); then
#		echo "===> Suspicious yoda file : $i with weight : $MYBINdn" 
#	fi
done
