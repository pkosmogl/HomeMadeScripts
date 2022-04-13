#!/bin/bash 

cd afspath
eval `scramv1 runtime -sh`        # this is the cmsenv
export X509_USER_PROXY=$1         # set path to proxy file
export HOME=$2                    # set path to home directory (otherwise ~/.dasmaps directory cant be accessed)

cmsRun cfg.py
