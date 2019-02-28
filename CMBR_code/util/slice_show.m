%%%input:video volume I
I_pad=padarray(I,[5 5 15],'both','replicate');
% I_pad=gauss_smooth( I_pad, [3,3,0], 'valid' );
D = double(squeeze(I_pad));
figure(1)
colormap(gray(256));
title('ewfe');
image_num = 8;
image(D(:,:,image_num));
colorbar;
axis image

%%% adjust the dimension of I
M=flipud(D);
M=permute(M,[3 2 1]);

n=size(I,3)-15;
f=figure(2);
hold on
colormap(gray(256))
h1=slice(M,[],fix(n/4),[]);
h1.FaceColor='interp';
h1.EdgeColor = 'none';
h2=slice(M,[],fix(n/2),[]);
h2.FaceColor='interp';
h2.EdgeColor = 'none';
h3=slice(M,[],fix(n*3/4),[]);
h3.FaceColor='interp';
h3.EdgeColor = 'none';
h4=slice(M,[],fix(n),[]);
h4.FaceColor='interp';
h4.EdgeColor = 'none';
colormap(gray(256))
view(-45,35);
% xlabel('width','FontSize',14);
% ylabel('time','FontSize',14);
% zlabel('height','FontSize',14);
set(gca,'color','none');
axis tight

%%%interest point show
findslide=(subs(:,3)==fix(n/4)|subs(:,3)==fix(n/2)|subs(:,3)==fix(n*3/4)|subs(:,3)==fix(n));
[index,~]=find(findslide);
x=subs(index,2);
y=subs(index,3);
z=240-subs(index,1);
s=zeros(length(index),1)+200;
c=repmat([255 0 0],[length(index),1]);
scatter3(x,y,z,s,c,'.');
scatter3(mean(x),mean(y),mean(z),300,'p','filled');
hold on
xlabel('width','FontSize',16)
ylabel('time','FontSize',16)
zlabel('height','FontSize',16)
xlim([0,320]);
zlim([0,240])
ylim([0,50])
axis tight