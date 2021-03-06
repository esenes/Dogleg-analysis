### tdms_struct data structure 

Every `Prod_<date>.mat` file is containing 2 variables, which are
* **field_names:** a cell array containing the list of fields of the *tdms_struct* 
**Note:** if not present can be easily generated using the command 

  ``` python
  field_names = fieldnames(tdms_struct)
  ```
* **tdms_struct:**  the real structure which is effectively containing the data

The inner structure of the *tdms_struct* inherits directly form the tdms structure of the binary file where the data are stored by the acquisition system. More info about the structure can be found in [this reference](http://www.ni.com/white-paper/5696/en/). This is also the motivation for the presence of the _Props_ field in every file, field and subfield.

**Note:** only the fields which were effectively used are commented

#### Example structure
In order to make the comprehension easier this is an example of the structure of the data:

* _Props_: which is containing the properties of the file
* *g_(date/time)_(flag)*
  * Props
    * INC_PW_threshold_Threshold
    * TRA_PW_threshold_Threshold
    * ...
  * INC
    * name
    * Props
      * wf_start_time
      * wf_increment
      * ...
    * data
  * TRA
    * ...
  * ...
* *g_(another date/time)_(another flag)*
* ...

#### internal structure of tdms_struct
every `tdms_struct` contains two types of fields:
* _Props_: which is containing the properties of the file
* *'g_(date/time)_(flag)'*: where
  * (date/time) is the timestamps in the format _yyyymmddHHMMSS_LLL_
  * (flag) is the flag for the event 
    * _B0_ for an event which triggered an interlock
    * _L1_ for the event precedent the _B0_
    * _L2_ for the event precedent the _L1_
    * _L0_ for the backup pulses, acquired once per minute if no interlock is triggered

#### internal structure of an event
into every interlock event are saved this general fields:
* __name__
* __Props__
  * INC_PW_threshold_Threshold
  * TRA_PW_threshold_Threshold
  * PW_Start_sample
  * PW_End_sample
  * PW_int_diff_
  * PW_diff_
  * REF_Threshold
  * KREF_Threshold
  * TRA_sample_offset
  * Breakdown_Flags
  * Pulse_Delta: counts the number of pulses from the precedent interlock

And the other fields are:

**The meaning of the field is:**
* __INC__  contains data on the incident power on the structure (from logaritmic detector)
* __TRA__ contains data on the transmitted power by the structure (from logaritmic detector)
* __REF__ contains data on the reflected power by the structure (from logaritmic detector)
* __KREF__ contains data on the reflected power to the xbox
* __BPM1__ contains data of the upstream Beam Position Monitor
* __BPM2__ contains data of the downstream Beam Position Monitor
* __BLM1__ contains data of the Beam Loss Monitor 1
* **Fast_BLM2** contains data of the Beam Loss Monitor 2
* **Fast_BLM3** contains data of the Beam Loss Monitor 3
* **diodeINC** contains data on the incident power on the structure (from diode detector)
* **diodeTRA** contains data on the transmitted power by the structure (from diode detector)
* **diodeREF** contains data on the reflected power by the structure (from diode detector)
* **Fast_INC_I** contains data on the incident I signal
* **Fast_INC_Q** contains data on the incident Q signal
* **Fast_REF_I** contains data on the reflected I signal
* **Fast_REF_Q** contains data on the reflected Q signal
* **Fast_TRA_I** contains data on the transmitted I signal
* **Fast_TRA_Q** contains data on the transmitted Q signal
* **INC_average**
* **INC_max**
* **INC_pulse_width**
* **TRA_max**
* **Motor_Right** useless with this pulse compressor

**The basic inside tructure of every data field is**
* **name**
* **Props** contains the properties of the DAQ system at the moment of the acquisition
  * **wf_start_time** timestamp generated by the PC saving the data (could be wrong !)
  * **wf_start_offset** 
  * **wf_increment** is the period of sampling in seconds
  * **wf_samples** is the number of samples per acquisition
  * **NI_ChannelName** is the channel name into the PXI
* **data** is a double array containing the data. The length is *wf_samples* acquired with a period of  *wf_increment*

**Note:** the other types of event do not have the same fields, in general the backup pulses have less fields.
