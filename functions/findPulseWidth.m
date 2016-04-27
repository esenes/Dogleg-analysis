function [ width_bins ] = findPulseWidth( data, nominal_PW, thr1, thr2, thr3, win_start, win_end )
%	findPulseWidth.m: returns the width of the pulse at the three tresholds
%
%   Inputs:
%   - data: data array
%   - nominal_Pw: nominal power setpoint, in fact the teoretical height of the pulse
%   - thr1, thr2, thr3: treshold on the setpoint in percentage. LOWER TO
%     HIGHER
%   - win_start, win_end: define of ROI in data
%   
%   Outputs:
%   - width_bins: is the width in bins of the three tresholds levels
%
%   CAVEAT: this algorithm works looking for the crossing of the tresholds,
%   and start testing point by point from left. This means that can not
%   converge in case of flattop not flat ...... 
%
%   Last modified: 21.04.2016 by Eugenio Senes


thrs = [thr1,thr2,thr3];
thrs = [thrs fliplr(thrs)];

j=0;
flags = false(1,length(thrs));
flagptr = 1;
%check left treshold crossing
while j < win_end-win_start 
    %check treshold overcome
    if inc(j + win_start-1) > thrs(flagptr) && flags(flagptr) == false && flagptr <= 0.5*length(thrs)
        %look for the first thr
        out(flagptr) = (j+ win_start-2);
        line([out(flagptr) out(flagptr)], ylim, 'Color', 'm','LineWidth',1) %vertical line
        flags(flagptr) = true;
        flagptr = flagptr+1;
    elseif inc(j + win_start-1) < thrs(flagptr) && flags(flagptr) == false && flagptr > 0.5*length(thrs)
        %look for the first thr
        out(flagptr) = (j+ win_start -1);
        line([out(flagptr) out(flagptr)], ylim, 'Color', 'c','LineWidth',1) %vertical line
        flags(flagptr) = true;
        %last iteration correction
        if flagptr ~= length(thrs)
            flagptr = flagptr+1;
        end
    end
    j = j+1;
end
cross1 = out(1:0.5*end);
cross2 = out(0.5*end+1:end);
cross2 = fliplr(cross2);
width_bins = cross2-cross1;

end

