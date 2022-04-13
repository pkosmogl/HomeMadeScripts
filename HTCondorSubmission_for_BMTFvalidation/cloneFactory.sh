#!/bin/bash

### Only dataset and gTag variables need to be set in the original python configuration file ###

if [ "$#" -ne 9 ]
then
   echo
   printf "=%.0s" {1..73}; printf "\n"
   echo "Usage:   $0  <python file> <Nevents> <lumi start> <lumi step> <lumi stop> <run number> <submission file> <job flavor> <executable file>"
   printf "=%.0s" {1..73}; printf "\n"
   echo "python file         ---> the cfg file to be cloned"
   echo "Nevents             ---> number of events"
   echo "lumi start          ---> start from Lumi Section" 
   echo "lumi step           ---> step between Lumi Section start/stop"
   echo "lumi stop           ---> stop to Lumi Section"
   echo "run number          ---> run number of interest"
   echo "submission file     ---> submission file used in condor_submit"
   echo "job flavor          ---> choose one from the following list:"
   echo "                         - espresso     (20 min)"  
   echo "                         - microcentury (1 hour)"
   echo "                         - longlunch    (2 hour)"
   echo "                         - workday      (8 hour)"
   echo "                         - tomorrow     (1 day)"
   echo "                         - testmatch    (3 days)"
   echo "                         - nextweek     (1 week)"
   echo "executable file     ---> executable file used for cmsRun"
   printf "=%.0s" {1..73}; printf "\n"
   echo
   exit 1
fi

# Take aruments
pyfile=$1                                    # Python file name
pyNoDot=$(echo "$pyfile" | cut -f 1 -d '.')  # Remove the .py extension from python file name

Nevents=$2  # Number of events
Lstart=$3   # Lumi Section start, min range
step=$4     # Lumi Section step
Lstop=$5    # Lumi Section stop, max range
runNum=$6   # Run number

LSintervals=($(seq $Lstart $step $Lstop))  # Lumi intervals
Nclones=$((${#LSintervals[@]} - 1))        # Number of python file clones to be created

subfile=$7                                     # submission file used in condor_submit
subNoDot=$(echo "$subfile" | cut -f 1 -d '.')  # Remove the .sub extension from submission file name

flav=$8  # Job flavor

exefile=$9                                     # executable file used for cmsRun
exeNoDot=$(echo "$exefile" | cut -f 1 -d '.')  # Remove the .sh extension from submission file name

# Create clones of python, submission and executable files
echo "Creating $Nclones python file clones..."
echo "Creating $Nclones submission file clones..."
echo "Creating $Nclones executable file clones..."
for ((i = 0 ; i < $Nclones ; i++)) 
do
   j=$(($i + 1))
   ext=_"$runNum"RunNumber_"$Nevents"Events_"${LSintervals[$i]}"LS_"$((${LSintervals[$j]} - 1))"LS
   newpy="$pyNoDot""$ext".py
   newsub="$subNoDot""$ext".sub
   newexe="$exeNoDot""$ext".sh

   sed 's@events = 100@events = '$Nevents'@' $pyfile > ./Run_348776_validationDate_06_April_2022/$newpy
   sed -i 's@run = "[0-9]*"@run = "'$runNum'"@' ./Run_348776_validationDate_06_April_2022/$newpy
   sed -i 's@lumiBegin = "[0-9]*"@lumiBegin = "'${LSintervals[$i]}'"@' ./Run_348776_validationDate_06_April_2022/$newpy
   sed -i 's@lumiEnd = "[0-9]*"@lumiEnd = "'$((${LSintervals[$j]} - 1))'"@' ./Run_348776_validationDate_06_April_2022/$newpy

   sed 's@exe.sh@'$newexe'@' $subfile > ./Run_348776_validationDate_06_April_2022/$newsub
   sed -i 's@output\/output.out@output\/output'$ext'.out@' ./Run_348776_validationDate_06_April_2022/$newsub
   sed -i 's@error\/error.err@error\/error'$ext'.err@' ./Run_348776_validationDate_06_April_2022/$newsub
   sed -i 's@log\/log.log@log\/log'$ext'.log@' ./Run_348776_validationDate_06_April_2022/$newsub
   sed -i 's@flavour@'$flav'@' ./Run_348776_validationDate_06_April_2022/$newsub

   sed 's@afspath@'$PWD'\/Run_348776_validationDate_06_April_2022@' $exefile > ./Run_348776_validationDate_06_April_2022/$newexe
   sed -i 's@cfg.py@'$newpy'@' ./Run_348776_validationDate_06_April_2022/$newexe 
done
echo "Done"

# Create directories error - log - output
cd ./Run_348776_validationDate_06_April_2022

if [ ! -d error ]; then mkdir error; fi
if [ ! -d log ]; then mkdir log; fi
if [ ! -d output ]; then mkdir output; fi
