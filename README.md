# Dogleg-analysis
The following scripts are intended to analyze the data of the test of the TD26 structure, under test in the dogleg of the CTF3 facility.
The data are stored in TDMS files, to perform the analysis run these scripts in sequence:

1) __read_TDMS_full.m__

to read the TDMS files in the specified range and convert TDMS files into `Prod_<date>.mat` files. 
The content of the files are all the events which have triggered an interlock and the backup pulses.

This script with the relative subfunctions is available in another repository named [TDMStoMAT](https://github.com/esenes/TDMStoMAT)

2) __readMATandsort.m__

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
* datapath_read:  the path containing the `Prod_<date>.mat` files (without \ at the end)
* datapath_write: the path of location to save data files (without \ at the end)
* startDate = start date in the format 'yyyymmdd'
* endDate =   end date in the format 'yyyymmdd'
* startTime = start time in the format 'HH:MM:SS'
* endTime =   end time in the format 'HH:MM:SS'
* buildExperiment = true/false, at the end of the execution reads every file in the data folder and merges it a new file
* expName = the name of the output file if merging the data files

The full reference is available [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/readMATandsort_guide.md)

3) __Filtering.m__

still a work in progress.... 



#### Useful stuff:
* [tdms_struct structure reference](https://github.com/esenes/Dogleg-analysis/blob/master/manual/tdms_struct%20structure.md)
* [tdms_struct structure reference]()
