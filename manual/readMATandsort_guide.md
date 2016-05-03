# readMATandsort.m reference

This file means to be the detailed explanation of how readMATandsort.m works and which is the idea behind the algotyrhm.

#### What we've got

In every `Prod_<date>.mat` file is contained a structure named *tdms_struct* which cointains a field per every event registered.
There are two types of fields:

1. Ending with *L0*: are backup pulses, acquired once per minute if no interlock is triggered
2. Ending with *B0, L1, L2*: are the interesting events which have triggered one of the interlocks
  * _B0_: is the event which triggered a interlock
  * _L1_: is the previous pulse to the interlock
  * _L2_: is the pulse before the previous pulse

For every field are saved a lot of subfields containing the incident, transmitted and reflected power and a lot of more informations from the acquisition system.
The complete reference to the content of the structure is available on the  [tdms_struct reference page](https://github.com/esenes/Dogleg-analysis/blob/master/manual/tdms_struct%20structure.md)


#### What is the idea behind the algorythm

As it's easy to understand, the backup pulses are useless during the normal data analysis, and dealing with big files filled of useless data is not a great idea, so first of all the algorythm should select just the events which have triggered an interlock.
The point is that **no more discard of data and manipulation is made in this stage of analysis**, the aim of the script is to **classify the data**, adding information but without lose the original one.

The process can be resumed in

* calculate and add the calibrated signals
* estimate if the breakdown happened into the structure or into the waveguides
* detect if the interlock was triggered by a spike

##### Comment on the performance

The choice of using a structure insthead of arrays has been criticized due to the minor performance which is intrinsic in the use of  structures. This choice is motivated by the need of having a data structure which is easily understandable even after long time.

Anyway apart for the use of the structure, Theo and me put a lot of efforts in the optimization of the algorythm as much as our progamming skills allow us.

#### The workflow

Now it's time to enter in the details: the files `Prod_<date>.mat` are opened one by one and only the fields ending with _B0_ ,_L1_ and _L2_ are used, while the backup events ending with the _L0_ are discarded and not saved anymore. Please note that not every  _B0_ file have the backup pulses.

For the _B0_ ,_L1_ and _L2_ events:
* Are calculated and stored the **calbrated signals** for INC, TRA and REF and for both the upstream (BPM1) and downstream (BPM2) beam position monitors
* Is calculated and stored the **sum of the BPMs signals** in order to apply a treshold later to detect the prescence of the beam, but no selection is done at the moment

Additionally for the _B0_ files:
* Are calibrated the **IQ signals** and saved the _amplitude_, _phase_ and _timescale_IQ_ for INC, REF and TRA power
* Is calculated the **number of pulses between the breakdowns**
* Are calculated and saved the two **metrics**

![metrics](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/metrics.jpg) 
 
* Are applied algorithms for the **spike detection**
 * The [fast algorithm](https://github.com/esenes/Dogleg-analysis/blob/master/manual/fastSpike.md) compares the difference between the _B0_ pulse and the previous two pulses (is applied only when both the backup pulses are available). Please note that is designed to trhrow an error very easily in order to avoid positive falses. In every case of indecision, the other algorithm is triggered.
 * The digital filter is applied in all the other cases or when the prevous algorithm fails. More infos on the filter design are available [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/freqSpike.md)

* Is applied an algorithm to detect the **proper tuning of the klystron** compressed pulse, more infos [here](https://github.com/esenes/Dogleg-analysis/blob/master/manual/tuningCheck.md)

At the end of the processing of every `Prod_<date>.mat` file is saved a file named `Data_<date>.mat` with the selected events (everything but the backup events) and the program skip to the next file.

A last field named **pulses_from_last_BD** is added to keep track of the number of pulses from the last breakdown in the next file.

#### Parameters
Two algorithms have parameters which can be setted by the user in this section:

1. **Spike** algorithm
 * Windowing : the start and end of the signal used in bins
   * spike_window_start
   * spike_window_end 
 * Treshold
   * spike_thr: treshold in watts
   * ratio_setPoint: percentage of the integral power to make the fast algorythm fail

2. **PC tuning**
 * Windowing : the start and end of the signal used in bins for compressed pulse and the flattop
  * comp_pulse_start
  * comp_pulse_end
  * flattop_start
  * flattop_end
 * Tresholds: percentage of the max of the signal where to take the reference points
  * thr1
  * thr2


#### Build the experiment file
When every file has been processed, it is possible to build a unique file which is contaning the whole interlocks events for the considered time period. This feature is accessible setting
```python
buildExperiment = true
```
in the initialization section on top. 

The process require some time and a discrete amount of RAM memory, the output file is generally some GB big.

**Important note:** this feature is intended to assembly file concerning the same data acquisition, every other use will lead to mistified data.

The idea is to create an experiment file per every row of the table in the [cern Dogleg-operation wiki](https://wikis.cern.ch/display/CTF3OP/TD26+Structure+runnings) (which unfortunately is accessible just from inside the cern network) 

![table](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/Screenshot%202016-05-02%2016.30.07.png)

(Last table update: 02.05.2016)

#### The data structure
Into both the experiment file and every `Data_<date>.mat` file the data are contained into a structure called `data_struct` with the same fields. For more infos see the [data_struct reference page](https://github.com/esenes/Dogleg-analysis/blob/master/manual/data_struct%20structure.md)
