#!/bin/bash 

cd $4
eval `scramv1 runtime -sh`        # this is the cmsenv
export X509_USER_PROXY=$3         # set path to proxy file
export HOME=$2                    # set path to home directory (otherwise ~/.dasmaps directory cant be accessed)

cmsRun $1
