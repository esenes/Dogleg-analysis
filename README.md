# Dogleg-analysis
The following scripts are intended to analyze the data of the test of the TD26 structure, under test in the dogleg of the CTF3 facility.
The data are stored in TDMS files, to perform the analysis run these scripts in sequence:

### 1) read_TDMS_full.m

to read the TDMS files in the specified range and convert TDMS files into `Prod_<date>.mat` files. 
The content of the files are all the events which have triggered an interlock and the backup pulses.

This script with the relative subfunctions is available in another repository named [TDMStoMAT](https://github.com/esenes/TDMStoMAT)

### 2) readMATandsort.m

reads the files `Prod_<date>.mat`, discard the backup pulses, perform a first analysis and save as output files named `Data_<date>.mat`.
If `buildExperiment=true` the Data files are merged in `Exp_<expname>.mat`.
This feature is intended to group a long data acquisition into a single file. (link to the table on the wikis)

_The aim of the script is:_
- select just interlocks discarding the backup pulses
- save fields for the calibrated signals for INC, TRA, REF, IQs (for all three)
- calculate and save the metric (both INC-TRA and INC-REF)
- save fields for the calibrated signals of BPMs and the integral of the signals (-> info on charge)
- detect spikes, using or a digital filter or the comparison with the previous pulse
- detect if the Xbox's pulse compressor is properly tuned (WORK IN PROGRESS ...)

_User input_
* **datapath_read**:  the path containing the `Prod_<date>.mat` files (without \ at the end)
* **datapath_write**: the path of location to save Data files (without \ at the end)
* **exppath_write**: the path of location to save the Experiment files (without \ at the end)
* **startDate** = start date in the format 'yyyymmdd' 
* **endDate** =   end date in the format 'yyyymmdd'
* **startTime** = start time in the format 'HH:MM:SS'
* **endTime** =   end time in the format 'HH:MM:SS'
* **buildExperiment** = true/false, at the end of the execution reads every file in the data folder and merges it a new file
* **expName** = the name of the output file if merging the data files

The full reference is available [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/readMATandsort_guide.md)

### 3) Filtering.m

to apply the filters to the informations which were calculated and saved in the precedent step of the analysis.

It reads directly the `Exp_<expname>.m` file and performs several analysis actions, which are:

__1) Flag the events__: assign a boolean value comparing every feature with user-defined tresholds; in detail:
*  detect if the event is **into the metric** or out of it
*  check if the **beam is present** for the BD under examination
*  check if the BD is **provoked by a spike**
*  check if the BD is provoked by a **beam lost**
  
__2) Select the events__: using the flags are built lists of relevants events (e.g. spikes, BDs into the metric with beam, ....)

__3) Calculate the delay between the transmitted and incident power__

__4) Plot the events distribution__: many distributions are displayed (e.g. BDR, peak and average incident power, tuning of the pulse, BD cluster length)



still a work in progress.... 



#### Data structure:
* [tdms_struct structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/tdms_struct%20structure.md)
* [data_struct structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/data_struct%20structure.md)
* [experiment file data structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/experiment%20files.md)
