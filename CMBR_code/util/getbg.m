function template = getbg( left,right )
%GETBG Summary of this function goes here
%   Detailed explanation goes here
if(size(left)==size(right))
lefttemplate=left(:,1:round(size(left,2)/2));
righttemplate=right(:,(size(right,2)-round(size(left,2)/2)+1):size(right,2));
template=cat(2,lefttemplate,righttemplate);
end

end

