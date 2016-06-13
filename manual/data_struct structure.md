### data_struct data structure 

Every `Data_<date>.mat` file is containing the copy of the interlock events with the relative backup pulses stored into the structure `data_struct`. Hence the internal structure is

* *Props*: props of the file, useful in the future ???
 * datatype
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
* *pulse_delay_from_last*

#### fields added respect to tdms_struct

into every interlock event are added these fields:
* __Props__
  * timestamp: in the format `dd-mm-yyyy HH:MM:SS.FFF`
  * Prev_BD_Pulse_Delay: the number of pulses past from the last interlock event
* __INC__
  * data_cal: calibrated data for the log detector
  * avg
    * INC_avg
    * start: start bin
    * end: end bin
  * max: max of the calibrated power
* __TRA__
  * data_cal: calibrated data for the log detector
  * max: max of the calibrated power
* __REF__
  * data_cal: calibrated data for the log detector
  * max: max of the calibrated power
* **Fast_INC_I**
  * Amplitude
  * Phase
  * timescale_IQ
* **Fast_TRA_I**
  * Amplitude
  * Phase
  * timescale_IQ
* **Fast_REF_I**
  * Amplitude
  * Phase
  * timescale_IQ
* __inc_tra__: the first metric
* __inc_ref__: the second metric
* **BPM1**
  * data_cal: calibrated data
  * sum_cal: the sum of the signal of the BPM for the current event
* **BPM2**
  * data_cal: calibrated data
  * sum_cal: the sum of the signal of the BPM for the current event
* **BPM1**
  * data_cal: calibrated data
  * sum_cal: the sum of the signal of the BPM for the current event
* **spike**
  * flag: boolean, 1 is a spike
  * method: the name of the algorithm used for the spike detection
    In case of spike, for the spike algorithm are added the fields:
    * method = 'Prev_pulses'
    * thr1: treshold used while comparing current event and previous pulse
    * thr2: treshold used while comparing current event and the pulse before the previous
    while for the digital filter are:
    * method = 'Freq_filter'
    * filtered_signal
* **tuning** 
  * fail_m1: error flag for method 1
  * top: result of method 1, top threshold
    *  x1
    *  x2
    *  xm
    *  y
    *  thr
  * mid: result of method 1, top threshold
    *  x1
    *  ...
  * bot: result of method 1, bottom threshold
    *  x1
    *  ...
  * fail_m2: error flag for method 2
  * slope: result of the method 2

and these fields are deleted
* **INC_average**: is recalculated and saved into the INC.avg field, which contains the boundary bins used for the calculation
* **INC_MAX**: is recalculated and saved into the INC.max field
* **INC_pulse_width**
* **Motor_right**
* **Motor_left**
