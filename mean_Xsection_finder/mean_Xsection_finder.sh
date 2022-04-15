#!/bin/bash

# In this script we find the average of cross sections of given files
# We run over all the files, which came as output after the rivet Powheg+Pythia8CUETM1
# We then search for the specific line that contains the cross section value, via grep command
# Where then we print the last matching of the grep command, via tail command
# Finally we have obtained the lines that contain the information that we need and we isolate the number (the value that we want), via the awk command (cut command also works)

SUM=0
INDEX=0
echo "==================================================="

for i in *.o*; do
	TEMP1=$(grep "Les Houches User" $i | tail -1 | awk '{print $12}')
	TEMP2=$(printf %.10f $TEMP1)

	if (( "`echo "$TEMP2 == 0.0" | bc`" )); then  # Some files have zero cross section, which we want to exclude from the average calculation
      echo "===> $TEMP2 <=== EXCLUDED from Calculation!!!"
      continue
   fi

	echo "===> $TEMP2"
	SUM=$(echo "$SUM + $TEMP2" | bc)
	INDEX=$(($INDEX + 1))
done

echo "==================================================="
echo "===> SUM=$(printf %e $SUM)"
echo "===> INDEX=$INDEX"
AVERAGE=$(echo "$SUM / $INDEX" | bc -l)
echo "===> AVERAGE=$(printf %e $AVERAGE)"
echo "==================================================="

