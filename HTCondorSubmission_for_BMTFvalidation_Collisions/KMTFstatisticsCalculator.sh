#!/bin/bash

SumEvents=0
SumEmulatorMuons=0
SumDataMuons=0
SumPt=0
SumPhi=0
SumEta=0
SumWheel=0
SumSize=0
for i in ./kmtfFiles/KMTF*
do
   # Find and take the numbers from the KMTF files
   TempEvents1=$(grep "Processed Events" $i | awk '{print $3}')
   TempEmulatorMuons1=$(grep "Emulator #Muons" $i | awk '{print $3}')
   TempDataMuons1=$(grep "Data #Muons" $i | awk '{print $3}')
   TempPt1=$(grep "pt Mismatches" $i | awk '{print $3}')
   TempPhi1=$(grep "phi Mismatches" $i | awk '{print $3}')
   TempEta1=$(grep "eta Mismatches" $i | awk '{print $3}')
   TempWheel1=$(grep "wheel Mismatches" $i | awk '{print $3}')
   TempSize1=$(grep "size Mismatches" $i | awk '{print $3}')

   # Convert string to integer number so we can do calculations
   TempEvents2=$(printf %d $TempEvents1)
   if (($TempEvents2 == 200000))
   then
      echo "===> $i probably exceeds 200000 processed events"
   fi
   TempEmulatorMuons2=$(printf %d $TempEmulatorMuons1)
   TempDataMuons2=$(printf %d $TempDataMuons1)
   TempPt2=$(printf %d $TempPt1)
   TempPhi2=$(printf %d $TempPhi1)
   TempEta2=$(printf %d $TempEta1)
   TempWheel2=$(printf %d $TempWheel1)
   TempSize2=$(printf %d $TempSize1)

   # Calculate Sum
   SumEvents=$(($SumEvents + $TempEvents2))
   SumEmulatorMuons=$(($SumEmulatorMuons + $TempEmulatorMuons2))
   SumDataMuons=$(($SumDataMuons + $TempDataMuons2))
   SumPt=$(($SumPt + $TempPt2))
   SumPhi=$(($SumPhi + $TempPhi2))
   SumEta=$(($SumEta + $TempEta2))
   SumWheel=$(($SumWheel + $TempWheel2))
   SumSize=$(($SumSize + $TempSize2))
done

echo
echo "SUMMARY" > KMTF_mismatchesFile_Final
echo "===================================================" >> KMTF_mismatchesFile_Final
echo "Processed Events:" $SumEvents >> KMTF_mismatchesFile_Final
echo "Emulator #Muons:" $SumEmulatorMuons >> KMTF_mismatchesFile_Final
echo "Data #Muons:" $SumDataMuons >> KMTF_mismatchesFile_Final
echo "pt Mismatches:" $SumPt >> KMTF_mismatchesFile_Final
echo "phi Mismatches:" $SumPhi >> KMTF_mismatchesFile_Final
echo "eta Mismatches:" $SumEta >> KMTF_mismatchesFile_Final
echo "wheel Mismatches:" $SumWheel >> KMTF_mismatchesFile_Final
echo "size Mismatches:" $SumSize >> KMTF_mismatchesFile_Final
echo
