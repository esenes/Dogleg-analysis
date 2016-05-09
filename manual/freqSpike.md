### Frequency based spike detection algorithm

This algorithm is in the subscript named [filterSpikes_W.m](https://github.com/esenes/Dogleg-analysis/blob/master/functions/filterSpikes_W.m) and uses a digital filter to filter the spikes.

The subscript is just limiting to apply the filter `Hd` to the signal and check if the signal is still over the treshold after the filtering. The treshold is tuned to use a FIR passband digital filter of 10th order, within 15 and 50 MHz.

The design of such filter is generally made once per file befor to call the subscript, for example
```matlab
dt = tdms_struct.(field_names{i}).INC.Props.wf_increment;
fs = 1/dt;
d = fdesign.bandpass('N,F3dB1,F3dB2',10,15e6,50e6,fs);
Hd = design(d,'butter');
```
and it's done like that in order to read from the tdms_struct the sampling period.

The filter used for our analysis is this:

![filter](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/DigFilter.bmp)

(updated 02.05.2016)
