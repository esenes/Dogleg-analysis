# filtering.m reference

This file wants to be the detailed explanation of how filtering.m works and which is the idea behind the algotyrhm.

#### What we've got

In every `Data_<date>.mat` file is contained a structure named *data_struct* which cointains a field per every interlock event.
Only the 'B0' files are considered now, for the fields content please refer to the [data_struct reference page](https://github.com/esenes/Dogleg-analysis/blob/master/manual/data_struct%20structure.md)


#### What is the idea behind the algorythm

The precedent step of analysis is providing a lighter data structure, which contains just the interlock events and adds some informations to every event such as the calibration data.

The analysis procedes in two steps:
1. The events are flagged with booleans according to various parameters (e.g. into the metric, is a spike, has the beam, ...)
2. Using the flags a list of the interesting timestamps is built

Then the data are plotted and the output is generated

The flagging process can be resumed in

* event into/out of the two metrics
* event is a spike or not (actually the filtering is made in the precedent stage of analysis and here is just used the flag which already exists)
* event with or without the beam
* event which are secondaries breakdowns provoked by a spike or triggered by a BD happened when there was no beam

