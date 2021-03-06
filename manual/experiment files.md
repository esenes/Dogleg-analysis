### data_struct structure in Experiments files

The structure of the files `Exp_<expname>.mat` file is based on the `Data_<date>.mat` but is missing the field *pulse_delay_from_last* at the end of the file (the pulse delay is inherited from a file to another one while merging the data files) and the content of the field called *Props* is different.

So an example of the internal structure of the experiment files is:

* *Props*
  * startDate: in format _yyyymmdd_
  * startTime: in format _HH:MM:SS_
  * endDate
  * endTime
* *g_(date/time)_(flag)*
  * Props
    * INC_PW_threshold_Threshold
    * ...
  * INC
    * name
    * Props
      * wf_start_time
      * ...
    * data
  * TRA
    * ...
  * ...
* *g_(another date/time)_(another flag)*
* ...
