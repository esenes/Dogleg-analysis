### Compressed pulse tuning check algorythm

This algorithm uses two different methods to check if the compressed pulse is nominal or the pulse compressor is detuned:

1. The **width algorithm** measure the width of the pulse at 3 different levels in the pulse (default 85%, 65% and 40% of the maximum)
2. The **slope algoritm** fits a straight line through the points of the flattop and extrapolate the slope, which will be used to detect if the pulse is nominal or not.

Please note that in the `readMATandsort.m` script are only calculated slope and widths, but the pulses are not tagged as tuned/detuned

#### Width algorithm

The **width** algorithm calculate uses the width of the pulse at three different tresholds and the center of the interval at that power level. The disalignment of the centers gives an information on the pulse shape (rememeber that the beam loading affects the rising edge !). 

The algorithm calculates the two intersection of the treshold and the pulse curve and the position of the point in the middle. Then a straight line could be fitted within the three central points and the slope of the line should be used as 'tilt indicator'. This last step is skipped in first istance in order to improve the performance, but can be performed during the filtering process in order to focus the analysis on a particular pulse shape or to exclude the detuned pulses.

![np1](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/nominal_p1.bmp)

The results of this algorithm are also useful to adjust the ROI for the Slope algoithm: the parameters are setted in the function call
``` matlab
checkTuning( INC_data, comp_pulse_start, comp_pulse_end, ...
            flattop_start, flattop_end, ft_end_offset, thr1, thr2, thr3  )
```
and the ROI is defined as the interval of pulse in the range (flattop_start:last_point_at_thr1 - ft_end_offset).

If this method is throwing a value which is smaller than *flattop_start*, then is used the user-defined parameter *flattop_end*.

#### Slope algorithm

The **slope algorithm** has been developed to detect this type of common situations

![sit](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/pjimage%20(1).jpg)

but fails is very patological situations. To partially avoid this, the points considered for the fitting are over the 85% treshold. If the window of the flattop overcomes thata point, the fitting interval is restricted to the interval (flattop_start:last_point_with_85%_power)


#### Final result

The final result is 

![fr](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/full_tilt.bmp)
