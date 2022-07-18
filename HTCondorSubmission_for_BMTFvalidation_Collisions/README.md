# HTCondor job submission for BMTF validation with Collisions
## Task
We want to perform validation checks of certain runs in the context of BMTF.  
The validation is usually performed by interactively running a `.py` file via `cmsRun`,  
like  
```bash
cmsRun validate_bothAlgos_Collisions.py run=353689 events=250000 dataset=/JetHT/Run2022A-v1/RAW gTag=123X_dataRun3_HLT_v11
```

If the run in question contains a lot of events, of the order of `500,000` or more,  
running only one job on all available events is time consuming and prone to machine crashes.

For this reason the scripts given here provide a way to make parallel job submission using  
the HTCondor. Each job runs on a differen LS range and on a subsample of the overall number of  
events.

## Getting started
After successfully following the instructions in [1] to install the BMTF validation package,  
one should first change a few lines of code to enable parsing different output names among the  
job submissions and thus avoid overwriting issues.
  
First go to `$CMSSW_BASE/src/ExternalCMSSW/MuonStudy/test/validate_bothAlgos_Collisions.py` file.  
1. Change L27 to:
```py
args.register("legacyTag", "BMTF2",
```
2. Change L31 to:
```py
args.register("kalmanTag", "BMTF",
```
3. Add some additional lines after L54 `"Last run to process (for multiple queries).")`:  
```py
  args.register("lumiBegin", 10,
                VarParsing.VarParsing.multiplicity.singleton,
                VarParsing.VarParsing.varType.int,
                "Lumisection to start.")
  args.register("lumiEnd", 20,
                VarParsing.VarParsing.multiplicity.singleton,
                VarParsing.VarParsing.varType.int,
                "Lumisection to end.")
```
4. Change L86 to:  
```py
print("The L1TMuonBarrelRcd can be either fetched form CondDB or from the fakeParams script.")
```
5. Change L98,99 to:
```py
lumiBegin = args.lumiBegin
lumiEnd = args.lumiEnd
```
6. Tip! You may need to change L125 to:  
```py
files += cms.untracked.vstring('root://cmsxrootd.fnal.gov/'+_file.strip() for _file in query_out)
```
to read the files with another "protocol", or
```py
files += cms.untracked.vstring('root://eoscms//eos/cms'+_file.strip() for _file in query_out)
```
to read the files directly from `EOS`. More tips may be found at [Twiki](https://twiki.cern.ch/twiki/bin/view/CMSPublic/CompOpsAAATroubleshootingGuide)  
7. Change L153 to: `print (files)`  
8. Change L155 to: `print (das_queries)`  
9. Uncomment L164 and change it to:  
```py
lumisToProcess = cms.untracked.VLuminosityBlockRange(str(str(run)+':'+str(lumiBegin)+'-'+str(run)+':'+str(lumiEnd) if query_type == "single" else ''))
```
10. Change L199 to: 
```py
+'_'+str(events if events >= 0 else 'all')+'Events_'+str(lumiBegin)+'LS_'+str(lumiEnd)+'LS.root')
```
11. Add an additional line below L233 `system = cms.string("KMTF"),`:
```py
system2 = cms.string("_run"+str(run)+"_"+str(events)+"Events_"+str(lumiBegin)+"LS_"+str(lumiEnd)+"LS"),
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
 
2. **Prepare execution file:**  
Change L8  
```bash
cmsRun validate_bothAlgos_Collisions.py run=353689 events=250000 lumiBegin=$4 lumiEnd=$5 dataset=/JetHT/Run2022A-v1/RAW gTag=123X_dataRun3_HLT_v11
```
so that it fits your needs. Above the job will be submitted for run `353689`, for `250000` events on the `/JetHT/Run2022A-v1/RAW` dataset  
with global tag `123X_dataRun3_HLT_v11`. This `cmsRun` command will submit one job for each lumisection range indicated by the  
`lumiBegin` and `lumiEnd` arguments. These arguments are passed from the submission file `submit.sh`.  

3. **Prepare submission file:**  
Create a directory inside `/test` called for example `Run_353689_validationDate_27_June_2022`.  
Copy `exe.sh` and `submit.sub` scripts inside the newly created directory `Run_353689_validationDate_27_June_2022`   
First make sure that you initiate your grid certificate. Copy your proxy `x509up_u` file (usually found in  
`/tmp/x509up_u`) somewhere inside your home directory, like `/afs/cern.ch/user/<u>/<username>/private/`.  
Open `submit.sub` and make sure to give the appropriate values to the `Proxy_path` (L22), `Home_path` (L27),  
`Run_path` (L28), `+JobFlavour` (L58) variables.  
Below L65 you need to specify the lumi section range in which is job will be submitted. Each row corresponds to a different submission  
and the first number corresponds to the value passed down to the `lsBegin` variable while the second number corresponds to the value  
passed down to the `lsEnd` variables.

4. **Make job submissions:**  
You probably need to create the `log`, output` and `error` directories inside `/test/Run_353689_validationDate_27_June_2022`  
for the output files of the job submissions.  
Then submit your jobs by running:
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
