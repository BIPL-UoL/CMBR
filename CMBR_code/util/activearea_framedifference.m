function [start_locs, end_locs,h_w] = activearea_framedifference( I )
%ACTIVEAREA_FRAMEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
stretchpars=[-15,-15,30,30];
% stretchpars=[0,0,0,0];
shiftI=uint8(zeros(size(I,1),size(I,2),size(I,3)));
shift=1;
shiftI(:,:,1:end-shift)=I(:,:,shift+1:end);
for i=0:shift
shiftI(:,:,end-i)=I(:,:,end);
end
fgmask=I-shiftI;
max_rects=[];
for i=1:size(fgmask,3)
    image=fgmask(:,:,i);
    thresh = graythresh(image);
    if thresh<0.1
        thresh=0.1;
    end
    image=im2bw(image,thresh);
    img_reg=regionprops(image,'area','boundingbox');
    if ~isempty(img_reg)
        areas=[img_reg.Area];
        rects=cat(1, img_reg.BoundingBox);
        [a, max_id] = max(areas);
        max_rect=rects(max_id,:);
        max_rect=max_rect+stretchpars;
        max_rects=cat(1,max_rects,max_rect);
%         imshow(image);  
%         rectangle('position', max_rect, 'EdgeColor', 'r');
    end
end
if ~isempty(max_rects)
max_r=[min(max_rects(1)) min(max_rects(2)) max(max_rects(3)) max(max_rects(4))];
start_loc=[min(max_rects(:,1)) min(max_rects(:,2))];
end_loc=[max_rects(:,1)+max_rects(:,3) max_rects(:,2)+max_rects(:,4)];
end_loc=max(end_loc,[],1);
start_locs=[round(start_loc(2)) round(start_loc(1)) 1];
end_locs=[round(end_loc(2)) round(end_loc(1)) size(I,3)];
h_w=((start_locs(1)-end_locs(1))-stretchpars(3))/((start_locs(2)-end_locs(2))-stretchpars(4));
else
    start_locs=[1,1,1];
    end_locs=[1,1,1];
    h_w=[];
end
% figure(7);
% imshow(I(:,:,end));  
% rectangle('position', [start_loc end_loc-start_loc], 'EdgeColor', 'r');
end

