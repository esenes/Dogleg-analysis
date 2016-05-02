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

Now it's time to enter in the details: the files `Prod_<date>.mat` are opened one by one and only the fields ending with _B0_ ,_L1_ and _L2_ are used, while the backup events ending with the _L0_ are discarded. Please note that not every  _B0_ file have the backup pulses.


