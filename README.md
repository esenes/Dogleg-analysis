# Dogleg-analysis
The following scripts are intended to analyze the data of the test of the TD26 structure, under test in the dogleg of the CTF3 facility.
The data are stored in TDMS files, to perform the analysis run these scripts in sequence:

1) __read_TDMS_full.m__

to read the TDMS files in the specified range and convert TDMS files into `Prod_<date>.mat` files. 
The content of the files are all the events which have triggered an interlock and the backup pulses.

2) __readMATandsort.m__

reads the files `Prod_<date>.mat`, discard the backup pulses, perform a first analysis and save as output files named `Data_<date>.mat`.
If `buildExperiment=true` the Data files are merged in `Exp_<expname>.mat`.
This feature is intended to group a long data acquisition into a single file.

_The aim of the script is:_
- select just interlocks discarding the backup pulses
- save fields for the calibrated signals for INC, TRA, REF, IQs (for all three)
- calculate and save the metric (both INC-TRA and INC-REF)
- save fields for the calibrated signals of BPMs and the integral of the signals (-> info on charge)
- detect spikes, using or a digital filter or the comparison with the previous pulse


3) __Filtgering.m__

still a work in progress.... 
