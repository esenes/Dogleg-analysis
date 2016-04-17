function [ fo ] = get_dates( fi )
%	get_dates.m: get the name of files in the format 'Prod_<date>.mat' and
%	returns the same array cutting everything but the date
%
%   (in practical just turn files2analyse from matrix to cell array)
%   Last modified: 16.04.2016 by Eugenio Senes
    [len, ~ ] = size(fi);
    fo = {};
    for i = 1:len
        fo = [fo fi(i,:)];
    end    

    ff = {};
for i=1:length(fo)
    fo{i} = fo{i}(6:13);
end

end

