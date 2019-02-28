function [start_locs, end_locs,h_w] = activearea_window(I)
%FILTERCUBOIDS Summary of this function goes here
%   Author: JIANG ZHEHENG
load template template;
template=padarray(template,[5 5],'both','replicate');
stretchpars=[-15,-15,30,30];
templates=repmat(template,[1 1 size(I,3)]);
fgmask=templates-I;
max_rects=[];
for i=1:size(fgmask,3)
    image=fgmask(:,:,i);
    thresh = graythresh(image); 
    image=im2bw(image,thresh);
    img_reg=regionprops(image,'area','boundingbox');
    areas=[img_reg.Area];
    rects=cat(1, img_reg.BoundingBox);
    [a, max_id] = max(areas);
    max_rect=rects(max_id,:);
    max_rect=max_rect+stretchpars;
    max_rects=cat(1,max_rects,max_rect); 
    imshow(image);  
    rectangle('position', max_rect, 'EdgeColor', 'r');
end
max_r=[min(max_rects(1)) min(max_rects(2)) max(max_rects(3)) max(max_rects(4))];
start_loc=[min(max_rects(:,1)) min(max_rects(:,2))];
end_loc=[max_rects(:,1)+max_rects(:,3) max_rects(:,2)+max_rects(:,4)];
end_loc=max(end_loc);
start_locs=[round(start_loc(2)) round(start_loc(1)) 1];
end_locs=[round(end_loc(2)) round(end_loc(1)) size(I,3)];
h_w=((start_locs(1)-end_locs(1))-stretchpars(3))/((start_locs(2)-end_locs(2))-stretchpars(4));
figure(7);
imshow(image);  
rectangle('position', [start_loc end_loc-start_loc], 'EdgeColor', 'r');  




