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

