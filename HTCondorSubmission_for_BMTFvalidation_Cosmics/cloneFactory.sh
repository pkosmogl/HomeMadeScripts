#!/bin/bash

if [ "$#" -ne 9 ]
then
   echo
   printf "=%.0s" {1..125}; printf "\n"
   echo "Usage:   $0  <python file> <Nevents> <dataset> <run #> <gTag> <lumi start> <lumi step> <lumi stop> <directory>"
   printf "=%.0s" {1..125}; printf "\n"
   echo "python file         ---> the cfg file to be cloned"
   echo "Nevents             ---> number of events"
   echo "dataset             ---> the dataset to run upon"
   echo "run #               ---> run number of interest"
   echo "gTag                ---> global tag"
   echo "lumi start          ---> start from Lumi Section" 
   echo "lumi step           ---> step between Lumi Section start/stop"
   echo "lumi stop           ---> stop to Lumi Section"
   echo "directory           ---> directory to be created to store the python clones"
   printf "=%.0s" {1..125}; printf "\n"
   echo
   exit 1
fi

# Take aruments
pyfile=$1                                    # Python file name
pyNoDot=$(echo "$pyfile" | cut -f 1 -d '.')  # Remove the .py extension from python file name
if ! [[ "$pyfile" =~ ^.*\.py$ ]]; then
   echo "===> Error : Invalid python file!"
   exit 1
fi

Nevents=$2  # Number of events
runNum=$4   # Run number
Lstart=$6   # Lumi Section start, min range
step=$7     # Lumi Section step
Lstop=$8    # Lumi Section stop, max range
if ! [[ "$Nevents" =~ ^[0-9]+$ ]]; then
   echo "===> Error : Invalid number of events!"
   exit 1
elif ! [[ "$runNum" =~ ^[0-9]+$ ]]; then
   echo "===> Error : Invalid run number!"
   exit 1
elif ! [[ "$Lstart" =~ ^[0-9]+$ ]]; then
   echo "===> Error : Invalid LS to begin!"
   exit 1
elif ! [[ "$step" =~ ^[0-9]+$ ]]; then
   echo "===> Error : Invalid LS step!"
   exit 1
elif ! [[ "$Lstop" =~ ^[0-9]+$ ]]; then
   echo "===> Error : Invalid LS to stop!"
   exit 1
fi

dataSet=$3  # Dataset to run upon
globTag=$5  # Global Tag
direct=$9   # Create a new directory
if [ ! -d $direct ]; then mkdir $direct; fi
cd $direct

LSintervals=($(seq $Lstart $step $Lstop))  # Lumi intervals
Nclones=$((${#LSintervals[@]} - 1))        # Number of python file clones to be created

# Create clones of python, submission and executable files
echo "Creating $Nclones python file clones..."
echo "Path: $PWD"
for ((i = 0 ; i < $Nclones ; i++))
do
   j=$(($i + 1))
   ext=_"$runNum"RunNumber_"$Nevents"Events_"${LSintervals[$i]}"LS_"$((${LSintervals[$j]} - 1))"LS
   newpy="$pyNoDot""$ext".py

   sed 's@events = [0-9]*@events = '$Nevents'@' ../$pyfile > $newpy
   sed -i 's@dataset = ".*"@dataset = "'$dataSet'"@' $newpy
   sed -i 's@run = "[0-9]*"@run = "'$runNum'"@' $newpy
   sed -i 's@gTag = ".*"@gTag = "'$globTag'"@' $newpy
   sed -i 's@lumiBegin = "[0-9]*"@lumiBegin = "'${LSintervals[$i]}'"@' $newpy
   sed -i 's@lumiEnd = "[0-9]*"@lumiEnd = "'$((${LSintervals[$j]} - 1))'"@' $newpy
done
echo "Done"

# Create directories error - log - output
if [ ! -d error ]; then mkdir error; fi
if [ ! -d log ]; then mkdir log; fi
if [ ! -d output ]; then mkdir output; fi
exit 0
