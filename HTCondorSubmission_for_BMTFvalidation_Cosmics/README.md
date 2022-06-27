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

## Getting started
After successfully following the instructions in [1] to install the BMTF validation package,  
one should first change a few lines of code to enable parsing different output names among the  
job submissions and thus avoid overwriting issues.

First go to `$CMSSW_BASE/src/ExternalCMSSW/MuonStudy/test/validate_bothAlgos_Cosmics.py` file.   
1. Comment L34 (`print files`) and L35 (`print das_query`).  
2. Change L102 to:  
```py
fileName = cms.string('validation_run'+run+'_'+str(events if events >= 0 else 'all')+'Events_'+lumiBegin+'LS_'+lumiEnd+'LS.root')
```
3. Add an additional line below L146 `system = cms.string("KMTF"),`:
```py
system2 = cms.string("_run"+run+"_"+str(events)+"Events_"+lumiBegin+"LS_"+lumiEnd+"LS"),
```

Then go to `$CMSSW_BASE/src/ExternalCMSSW/MuonStudy/src/Validation_new.cc` file.  
1. Add an additional line below L102 `std::string system;`:  
```C++
std::string system2;
```
2. Add an additional line below L171 `system = iConfig.getParameter<std::string>("system");`:  
```C++
system2 = iConfig.getParameter<std::string>("system2");
```
3. Change L180 to `fout.open(system+system2+"_mismatchesFile");`  
4. Add an additional line below L751 `desc.add<std::string>("system", "BMTF");`:  
```C++
desc.add<std::string>("system2", "");
```

***Note*** that the *lines* (L*) indicated above might change as new versions of the package arrive.

## The workflow
 1. **Clone the repositroy:**  
 Clone this repository inside `$CMSSW_BASE/src/ExternalCMSSW/MuonStudy/test`, so you can gain  
 access to the scripts.  
 2. **Prepare python file clones:**  
 Run `cloneFactory.sh` script as `./cloneFactory.sh`. It promts the user for some arguments.  
 The arguments given in the `cloneFactory.sh` script will set some values for variables inside  
 the `validate_bothAlgos_Cosmics.py` file.  
 **Pay attention** to the Lumi Section arguments, as according to these the script will decide  
 how many clones (of the python file) to create.  
 Each clone has exactly the same set of variables (L20-L27) except that the lumi section range  
 changes according to the step that is provided in the argument of `cloneFactory.sh`.  
 
 ***Example***  
 ```bash
 ./cloneFactory.sh validate_bothAlgos_Cosmics.py 200000 /ExpressCosmics/Commissioning2022-Express-v1/FEVT 350174 122X_dataRun3_HLT_v4 1 25 151 Run_350174_validationDate_13_April_2022
 ```
***Description***  
The `cloneFactory.sh` will create 6 clones of `validate_bothAlgos_Cosmics.py` inside the newly created  
directory `Run_350174_validationDate_13_April_2022`. The first python file will start from `1LS` and end  
at `25LS`, and the last python file will start at `126LS` and end at `150LS`. So we have a step of `25LS`!  
Other variables like #events (`200000`), dataset (`/ExpressCosmics/Commissioning2022-Express-v1/FEVT`),  
run number (`350174`) and global tag (`122X_dataRun3_HLT_v4`), remain the same for all python clone files.

3. **Prepare submission file:**  
Copy `exe.sh` and `submit.sub` scripts inside the newly created directory `Run_350174_validationDate_13_April_2022`  
(`Run_350174_validationDate_13_April_2022` in the case of the above example).  
First make sure that you initiate your grid certificate. Copy your proxy `x509up_u` file (usually found in  
`/tmp/x509up_u`) somewhere inside your home directory, like `/afs/cern.ch/user/<u>/<username>/private/`.  
Open `submit.sub` and make sure to give the appropriate values to the `Proxy_path` (L24), `Home_path` (L29),  
`Run_path` (L30) and `+JobFlavour` (L60) variables.  

4. **Make job submissions:**  
Double check that the `submit.sub` and `exe.sh` are in the same directory as the clones of python files  
you just created. Then run:
```bash
condor_submit submit.sub
```
Your jobs should have now been submitted.  
You can monitor the status of your jobs by running:
`condor_q` or `condor_q --nobatch`, the latter giving a more detailed description of the status information.

5. Once all jobs have finished you can hadd the individual `.root` files into a final one  
that will represent the hole run.
7. Each job also produces a KMTF file. You can run ontop of them the `KMTFstatisticsCalculator.sh`  
script to calculate the missmatch fractions for the hole run.  
Make sure that you point `KMTFstatisticsCalculator.sh` script to the location of the KMTF files.

[1] [Panos github page](https://github.com/panoskatsoulis/ExternalCMSSW/tree/CMSSW_11_2_X)
