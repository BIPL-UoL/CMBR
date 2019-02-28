
%%%input: subs of interest points
figure(3);
x=subs(:,2);
y=subs(:,3);
z=240-subs(:,1);
s=zeros(length(subs),1)+30;
scatter3(x,y,z,s,'filled');
hold on
scatter3(mean(x),mean(y),mean(z),300,'p','filled');
xlabel('width','FontSize',24)
ylabel('time','FontSize',24)
zlabel('height','FontSize',24)
xlim([0,320]);
zlim([0,240])
ylim([0,50])