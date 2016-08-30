# Dogleg-analysis
The following scripts are intended to analyze the data of the test of the TD26 structure, under test in the dogleg of the CTF3 facility.
The data are stored in TDMS files, to perform the analysis run these scripts in sequence:
 

![workflow](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/flowchart.png)


### Convert data:
#### read_TDMS_full.m

to read the TDMS files in the specified range and convert TDMS files into `Prod_<date>.mat` files. 
The content of the files are all the events which have triggered an interlock and the backup pulses.

This script with the relative subfunctions is available in another repository named [TDMStoMAT](https://github.com/esenes/TDMStoMAT)

Please note that this process is completely unreated to the analysis, so this is a completely separated program and is not related with the rest of the analysis.

### Data analysis:

#### 1) setup.m

if this is the first time you run this set of scripts, running the setup creates the file `setup.dogleg` which contains the paths to the folders which are going to contain the analysed data.

The folders to specify are:
* **Prod data folder**: the one containing the `Prod_<date>.mat` files generated using read_TDMS_full.m
* **temp data folder**: where are stored the `Data_<date>.mat` files, which can be removed if readMATandSort.m succeded without errors
* **analyzed data folder**: which is going to contain the `Exp_<date>.mat` and the `Norm_full_<date>.mat` files
* **plot folder**: is the folder where to save the plots in .jpg format
* **fig folder**: is the folder where to save the plots in the .fig format

The suggested folder structure is the following:
```
.
├── data source folder       # contains the 'Prod_<date>.mat' files
├── ...                    
├── temp                     # place for the 'Data_<date>.mat' and 'Norm_<date>.mat' files
└── analyzed data            # place for the 'Exp_<name>.mat', 'Exp_analyzed_<name>.mat' and 'Norm_full_<date>.mat' 
    ├── plots                # place for the .jpeg plots
    └── figs                 # place for the .fig plots

```


#### 2) readMATandsort.m

reads the files `Prod_<date>.mat`, perform a first analysis and save an output file named `Data_<date>.mat` containing the interlocks events and a file named `Norm_<date>.mat` containing the backup pulses.
If `buildExperiment=true` the Data files are merged in `Exp_<expname>.mat` between the date of interest.
If `buildBackupPulses=true` the Norm files are merged in `Norm_full_<expname>.mat`.
This feature is intended to group a long data acquisition into a single file.

_The aim of the script is:_
- select just interlocks discarding the backup pulses
- save fields for the calibrated signals for INC, TRA, REF, IQs (for all three)
- calculate and save the metric (both INC-TRA and INC-REF)
- save fields for the calibrated signals of BPMs and the integral of the signals (-> info on charge)
- detect spikes, using or a digital filter or the comparison with the previous pulse
- detect if the Xbox's pulse compressor is properly tuned (WORK IN PROGRESS ...)

_User input_
* **startDate** = start date in the format 'yyyymmdd' 
* **endDate** =   end date in the format 'yyyymmdd'
* **startTime** = start time in the format 'HH:MM:SS'
* **endTime** =   end time in the format 'HH:MM:SS'
* **buildExperiment** = true/false, at the end of the execution reads every BD file in the data folder and merges it a new file 
* **expName** = the name of the output file if merging the data files
* **buildBackupPulses** = true/false, at the end of the execution reads every data file containing the backup pulses in the data folder and merges it a new file 
* **backupName** = name of the file containing all the backup pulses data for the current experiment

The full reference is available [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/readMATandsort_guide.md)

At this point the analysis forks in two branches: 
* To analyze the operation of the machine during the normal pulses is used the script *NormalOperationCheck.m* (3.1)
* To analyze the BD events is used the script *Filtering.m* (3.2)

#### 3.1) NormalOperationCheck.m 

Analyze the backup pulses of the files called `Norm_full_<expname>.mat` and print some plots to understand the stability of the machine. 

The typical output can be found [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/NormalOperationCheck.md)


#### 3.2) Filtering.m

> still a work in progress.... 

to apply the filters to the informations which were calculated and saved in the precedent step of the analysis.

It reads directly the `Exp_<expname>.mat` file and performs several analysis actions, which are:

__1) Flag the events__: assign a boolean value comparing every feature with user-defined tresholds; in detail:
*  detect if the event is **into the metric** or out of it
*  check if the **beam is present** for the BD under examination
*  check if the BD is **provoked by a spike**
*  check if the BD is provoked by a **beam lost**
*  check if a BD into the structure have provoked a **cluster of secondaries** breakdowns
  
__2) Select the events__: using the flags are built lists of relevants events (e.g. spikes, BDs into the metric with beam, ....)

__3) Calculate the delay between the transmitted and incident power__: this is made dynamically, with a resolution which is the sampling time of the sampler, 4 ns in the case of the *log detector*

__4) Plot and save the events distribution__: Peak and average incident power distribution, tuning of the pulse, BD cluster length(work in progress)

__5) Save the BD events for further analysis__

The detailed reference for this program is [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/filtering%20guide.md)

_User input_
* **expName**: the full name of the experiment file to load (e.g. 'Exp_Loaded43MW_1')
* **savename**: the name of output files 
* **positionAnalysis**: do the position analysis check one BD by one


_Parameters_
* **Metric**: tresholds for the metric
 * inc_ref_thr
 * inc_tra_thr
* **BPM CHARGE TRESHOLDS**
 * bpm1_thr
 * bpm2_thr
* **DELTA TIME FOR CLUSTER DETECTION**
 * deltaTime_spike
 * deltaTime_beam_lost
 * deltaTime_cluster
* **JITTER** 
 * sf:   sampling frequency
 * sROI: start of the region of interest for the Jitter detection
 * eROI: end of the ROI 

---

#### Data structure:
* [tdms_struct structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/tdms_struct%20structure.md)
* [data_struct structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/data_struct%20structure.md)
* [experiment file data structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/experiment%20files.md)
* [experimet analyzed data structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/Exp_analyzed%20data%20structure.md)
