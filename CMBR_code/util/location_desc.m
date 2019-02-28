function data=location_desc(DATASETS,data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data=cell2array(data);
for i=1:DATASETS.nclips
locations=DATASETS.subs{i};
if(~isempty(locations))
location=mean(locations,1);
data1(i,:)=[data(i,:) location(1) location(2)];
else
data1(i,:)=[data(i,:) 0 0];
end
end
data={data1};

