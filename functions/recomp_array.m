function [ result ] = recomp_array( in1, idx1, in2, idx2 )
%	recomp_array.m: after a separate calculation, place every element of
%	the input 1 at the place index1 and the same for input2
%   
%   Last modified: 19.05.2016 by Eugenio Senes

% initial check
if length(in1) ~= length(idx1) || length(in2) ~= length(idx2)
    error('wrong input')
end

result = zeros(1,length(idx1)+length(idx2));
result(idx1) = in1;
result(idx2) = in2;

end

