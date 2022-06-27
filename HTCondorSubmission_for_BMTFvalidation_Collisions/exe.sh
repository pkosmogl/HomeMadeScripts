#!/bin/bash 

cd $3
eval `scramv1 runtime -sh`        # this is the cmsenv
export X509_USER_PROXY=$2         # set path to proxy file
export HOME=$1                    # set path to home directory (otherwise ~/.dasmaps directory cant be accessed)

cmsRun validate_bothAlgos_Collisions.py run=353689 events=250000 lumiBegin=$4 lumiEnd=$5 dataset=/JetHT/Run2022A-v1/RAW gTag=123X_dataRun3_HLT_v11
