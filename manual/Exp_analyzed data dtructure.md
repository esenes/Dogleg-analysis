### Experiment analyzed files structure

The files `Exp_analyzed_<expname>.mat` file is containig some lists of flags and the data_struct based on the `Exp_<date>.mat`

The flag lists contained are:

* **BDs_ts**: list of the timestamps of the good breakdowns
* **isSpike**
* **inMetric**
* **sec_spike**: flag for secondaries from the beam
* **beam_lost**
* **sec_beam_lost**
* **hasBeam**
* **clusters**: is part of a cluster
* **data_struct**

The flagging is made in accordance with the parameters recorded in the field analysis of data_struct. 
If the positioning has been done, the events which are members of `BDs_ts` have the fields below. The other events are just copied.

An example of structure is 

* *Analysis*
  * positioning: is a bool
  * Metric
    * inc_ref_thr
    * inc_tra_thr
  * Beam
    * bpm1_thr
    * bpm2_thr
  * Clusters
    * deltaTime_spike
    * beam_lost
    * deltaTime_cluster
* *Props*
  * filetype: 'Experimet_analyzed'
  * startDate: in format _yyyymmdd_
  * startTime: in format _HH:MM:SS_
  * endDate
  * endTime
* *g_(date/time)_(flag)*
  * Props
    * INC_PW_threshold_Threshold
    * ...
  * position
    * edge
      * ind_REF
      * time_REF
      * ind_TRA
      * time_TRA
    * correlation
      * backupPulse
      * delay_time
      * gain (only if backup pulse is 1)
      
  * ...
* *g_(another date/time)_(another flag)*
* ...
