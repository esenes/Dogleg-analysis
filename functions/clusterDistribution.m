function [ clust_length ] = clusterDistribution( trig_list, cl_list )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

cl_idx = find(cl_list);
clust_length = []; %number of BDs in every cluster
clust_size = 0;
index = 0;
for b=1:length(cl_idx)
   disp(['Cluster start: ' num2str(cl_idx(b)) ' trigger event is ' num2str(trig_list(cl_idx(b)-1))])
   if b~=1 && trig_list(cl_idx(b)-1) == 1 %there is a new trigger event
       %save the old event
       index = index+1;
       clust_length(index) = clust_size;
       %start counting for the new cluster
       clust_size = 1;
   elseif b==length(cl_idx)
       clust_size = clust_size+1;
       index = index+1;
       clust_length(index) = clust_size;
   else
       clust_size = clust_size+1;
   end
   
end

end

