### Fast spike detection algorithm

This algorithm is in the subscript named [`spike_test_cal.mat`](https://github.com/esenes/Dogleg-analysis/blob/master/functions/spike_test_cal.m), and it works this way:

if the difference between the _B0_ incident power pulse and a previous one overcome the treshold for at least one of the backup pulses, then the event is flagged as spike, and the spike flag is setted true. 

The treshold is not fixed, but is moving on the average of the the difference between the breakdown pulse and the previous one.
This helps to avoid the detection of a klystron ramp-up as a spike.

##### Possible issues

1. **Bad windowing:** after a BD the INC power drops, and the tail is affected as well. Since the tail of the pulse is affected by this behaviour, the part of the pulse considered is only up to the end of the compressed pulse. If the window goes beyond the end of the compressed pulse, the difference between the signals is bigger, and the signal could be erroneously detected as a spike. In this case the 'Bad windowing' error is thrown.
2.  **Power setpoint change:** if in the previous pulse no beam was detected, and then the beam restarts and in the meanwhile an interlock is triggered, it is possible that a change of setpoint is detected as a spike (e.g. the precedent pulse had as maximum 15MW and the next is at full power at 43.3MW, blowing up the difference detween the two). In this if the difference between the intgrals of the two pulses is bigger than a certain percentage of the integral of the _B0_ pulse, the 'Setpoint has changed' error is thrown.

##### Comment

This algorithm is design specificately to be fast and fail easily, in order avoid to classify 'good pulses' as spikes.
