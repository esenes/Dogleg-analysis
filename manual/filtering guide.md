# filtering.m reference

This file wants to be the detailed explanation of how filtering.m works and which is the idea behind the algotyrhm.

#### What we've got

In every `Data_<date>.mat` file is contained a structure named *data_struct* which cointains a field per every interlock event.
Only the 'B0' files are considered now, for the fields content please refer to the [data_struct reference page](https://github.com/esenes/Dogleg-analysis/blob/master/manual/data_struct%20structure.md)


#### What is the idea behind the algorythm

The precedent step of analysis is providing a lighter data structure, which contains just the interlock events and adds some informations to every event such as the calibration data.

The analysis procedes in two main steps:
1. The events are flagged with booleans according to various parameters (e.g. into the metric, is a spike, has the beam, ...)
2. Using the flags a list of the interesting timestamps is built
3. The delay between the INC and the TRA pulses is calculated (this method minimizes the difference between the two signals in absolute value and store it into the data_struct)

Then the data are plotted and the output is generated

The flagging process can be resumed in

* event into/out of the two metrics
* event is a spike or not (actually the filtering is made in the precedent stage of analysis and here is just used the flag which already exists)
* event with or without the beam
* event which are secondaries breakdowns provoked by a spike or triggered by a BD happened when there was no beam


#### The positioning methods

## Jitter check

![J1](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/Jitter1.png)

Is performed checking the alignment of the first part of the uncompressed pulse using the signal of the BD and rthe previous signal. Rather than minimizing the difference of the signals, just checking the position difference of the maxima seems to work well in the resolution of ± 1 sampling period

![J2](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/Jitter2.png)

#### How to use this program

still to finish ...
