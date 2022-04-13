# HTCondor job submission for BMTF validation
## Task
We want to perform validation checks of certain runs in the context of BMTF.  
The validation is usually performed by interactively running a `.py` file via `cmsRun`,  
like `cmsRun thePythonFile.py`.  

If the run in question contains a lot of events, of the order of `500,000` or more,  
running only one job on all available events is time consuming and prone to machine crashes.

For this reason the scripts given here provide a way to make parallel job submission using  
the HTCondor. Each job runs on a differen LS range and on a subsample of the overall number of  
events.

For this example the `ExternalCMSSW/MuonStudy/test/validate_bothAlgos_Cosmics.py` [1] file will be used,  
which is designed to run on Cosmics runs. Some lines inside the `.py` have been changed,  
compared to the original one, in order to differentiate the produced output files of each job submission.  
Additionally `ExternalCMSSW/MuonStudy/src/Validation_new.cc` also is changed a bit to make sure that the  
directory that is created in the output `.root` files is the same, so that the hadd command works out  
of the box.

## The workflow
 1. Open the `.py` file and make sure that you fix the variable `dataset` and `gTag` to the  
desired values. Here for example these are set to `/ExpressCosmics/Commissioning2022-Express-v1/FEVT`  
and `122X_dataRun3_HLT_v4` respectively.  
***Note*** that `events`, `run`, `lumiBegin`, `lumiEnd` variables will be set later in an automatic  
manner through the use of the `cloneFactory.sh` script.
2. Open `submit.sub` script and make sure that the `Home_path` variable is set to the output of your  
systems `$HOME` variable.  
Initialize your grid certificate.  
Find and move your `x509up_u` proxy file to a directory like `$HOME/private`.  
Then set the `Proxy_path` variable to point to this file. Make sure that you give the full path.  
The `+JobFlavour` variable will be set by the `cloneFactory.sh` script.  
3. The `afspath` in `exe.sh` is set by the `cloneFactory.sh` script.  
4. Create a desired directory where the output files will be saved.  
Inside `cloneFactory.sh` this directory is set to `Run_348776_validationDate_06_April_2022`.  
Find and replace inside `cloneFactory.sh` all occurrences of the above directory with the one you just created.  
You are ready to run `cloneFactory.sh` script!  
It will create one copy of the `validate_bothAlgos_Cosmics.py`, `exe.sh` and `submit.sub`  
for each job that you want to submit to HTCondor.  
5. Loop over all sub files that were created and submit them to HTCondor, like:
```bash
for i in `ls -v *.sub`; do condor_submit $i; done
```
6. Once all jobs have finished you can hadd the individual `.root` files into a final one  
that will represent the hole run.
7. Each job also produces a KMTF file. You can run ontop of them the `KMTFstatisticsCalculator.sh`  
script to calculate the missmatch fractions for the hole run.  
Make sure that you point `KMTFstatisticsCalculator.sh` script to the location of the KMTF files.


[1] [Panos github page](https://github.com/panoskatsoulis/ExternalCMSSW/tree/CMSSW_11_2_X)
