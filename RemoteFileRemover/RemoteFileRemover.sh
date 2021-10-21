#!/bin/bash

# If script is run with no arguments, print instructions
if [[ $# -ne 4 ]]; then
   echo
   printf "=%.0s" {1..103}; printf "\n"
   echo "Usage: $0 <Certificate Initialization> <Host Name> <Path> <Number of Files>"
   printf "=%.0s" {1..103}; printf "\n"
   echo "Certificate Initialization ---> yes or no"
   echo "Host Name                  ---> remote host name that the files are stored"
   echo "Path                       ---> remote path to files to be deleted"
   echo "Number of Files            ---> number of files inside the path"
   printf "=%.0s" {1..103}; printf "\n"
   echo
   exit 1
fi

# Check if first argument is yes or no
CertInit=$1
#if ! [[ $CertInit == "yes" || $CertInit == "no" ]]; then
if ! [[ $CertInit =~ ^[yY][eE][sS]|[yY]|[nN][oO]|[nN]$ ]]; then
   echo "===> Error : First argument needs to be yes or no"
   exit 1
fi

# Check if remote host is listening
hostIP=$2
echo "===> Pinging $hostIP"
if ping -c 1 $hostIP; then
   echo "===> $hostIP is listening"
else
   echo "===> Error : $hostIP is not listening"
   exit 1
fi

# Check if remote host path exists
hostPath=$3
echo "===> Checking if $hostPath exists"
if xrdfs $hostIP stat $hostPath; then
   echo "===> $hostPath exists"
else
   echo "===> Error : $hostPath does not exist"
   exit 1
fi

# Check if number of files to be deleted is an integer
#### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ####
# Brief tutorial on regular expressions ---> regex              #
# Inside if statement "=~" means make a comparison with a regex #
# "[0-9]" means match with any single digit from 1 to 9         #
# "+" means more of the same (more than one digit)              #
# "^" means start of a string                                   #
# "$" means end of a string                                     #
#### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ####
numFiles=$4
if ! [[ "$numFiles" =~ ^[0-9]+$ ]] ; then
   echo "===> Error : Invalid number of files"
   exit 1
fi

# Initialize GRID certificate
if [[ $CertInit =~ [yY][eE][sS]|[yY] ]]; then
   echo "Initiating GRID certificate.."
   voms-proxy-init -voms cms -hours 192 -vomslife 192:0
   echo
fi

# Removing files from remote host path
echo "===> Removing all $numFiles files inside $hostPath"
for i in $(seq 1 $numFiles)
do
   echo "    Removing file : output_${i}.root"
   xrdfs $hostIP rm ${hostPath}/output_${i}.root
   exitCode=$?

   # Sometimes xrdfs command fails to remove a file
   # Rerun the command until succees
   counter=0
   while [[ $exitCode -ne 0 ]]
   do
      echo "        Retrying removing file : output_${i}.root"
      xrdfs $hostIP rm ${hostPath}/output_${i}.root
      exitCode=$?

      # Avoid infinite loops
      counter=$((counter + 1))
      if [[ $counter -eq 5 ]] 
      then
         echo "Error : Removal of output_${i}.root failed"
         exit 2
      fi
   done
done

# Removing directory from remote host path
while [[ $hostPath != "/store/user/pkosmogl" ]]
do
   echo "    Removing directory: $hostPath"
   xrdfs $hostIP rmdir $hostPath
   hostPath=${hostPath%/*}
done
