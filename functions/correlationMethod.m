function [coeff,gof,err] = correlationMethod( x1,y1,x2,y2,wind,tsignal)
    index_start = find(x1>=tsignal,1,'first');
    y1 = y1(index_start:end);
    y2 = y2(index_start:end);
    x1 = x1(index_start:end);
    x2 = x2(index_start:end);

    x1 = 1e9*x1(wind);
    y1 = y1(wind)-min(y1(wind));
    x2 = 1e9*x2(wind);
    y2 = y2(wind)-min(y2(wind));
    
%     x1 = 1e9*x1(wind);
%     y1 = abs(y1(wind));
%     x2 = 1e9*x2(wind);
%     y2 = abs(y2(wind));    

    x_offset = linspace(-100,130,500)';
    y_multipl = linspace(0.1,1.9,100);
    err = zeros(length(x_offset),length(y_multipl));

    for j=1:length(x_offset)

        x2_temp = x2+x_offset(j);
        y2_temp = interp1(x2_temp,y2,x1);
        noNaN_indexes = find(~isnan(y2_temp));    


        y2_temp_comp = y2_temp(noNaN_indexes)*y_multipl;
        y1_temp = y1(noNaN_indexes);

        err(j,:) = sum((y2_temp_comp-repmat(y1_temp,1,size(y2_temp_comp,2))).^2);
    end

    [~,min_i_multipl] = min(err,[],2);
    [min_v_offset,min_i_offset] = min(min(err,[],2));
    x_offset_min = x_offset(min_i_offset);%
    y_multipl_min = y_multipl(min_i_multipl(min_i_offset));

    coeff(1) = -x_offset_min;
    coeff(2) = y_multipl_min;

    gof = min_v_offset;
    
%     figure(111)
%     plot(x1, y1, x2, y2, x2-coeff(1), y2*coeff(2),'LineWidth',2)    
    








