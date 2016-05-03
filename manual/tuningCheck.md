### Compressed pulse tuning check algorythm

This algorithm uses two different methods to check if the compressed pulse is nominal or the pulse compressor is detuned:

1. The **slope algoritm** fits a straight line through the points of the flattop and extrapolate the slope, which will be used to detect if the pulse is nominal or not.
2. The **width algorithm** measure the width of the pulse at 2 different levels in the pulse (default 85% and 50% of the maximum)

Please note that in the `readMATandsort.m` script are only calculated slope and widths, but the pulses are not tagged as tuned/detuned

The **slope algorithm** has been developed to detect this type of common situations

![sit](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/pjimage%20(1).jpg)

but fails is very patological situations. To partially avoid this, the points considered for the fitting are over the 85% treshold. If the window of the flattop overcomes thata point, the fitting interval is restricted to the interval (flattop_start:last_point_with_85%_power)

The **width** algorithm calculate the width of the pulse at two different tresholds the center of the interval at that power level. The disalignment of the centers gives an information on the pulse shape (rememeber that the beam loading affects the rising edge !). 

![slp](https://github.com/esenes/Dogleg-analysis/blob/master/manual/images/slopeMet.bmp)
