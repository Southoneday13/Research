clc
clear
%Read the image
I=imread('hand.jpg');

%Convert to grayscale
Igray=rgb2gray(I);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question a~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Simple thresholding
level=graythresh(Igray);
Ibw=im2bw(Igray, level);

%how the images
figure
subplot(1, 2, 1);
imshow(Igray);
title('Grayscale Image');

subplot(1, 2, 2);
imshow(Ibw);
title('Binary Image');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question b~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Invert the binary image
Ineg=~Ibw;

%Show the images
figure
subplot(1, 2, 1);
imshow(Ibw);
title('Original Binary Image');

subplot(1, 2, 2);
imshow(Ineg);
title('Inverted Binary Image');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question c~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Estimate finger diameter
D=20; 					%This is just an example value, you need to estimate based on your own image

%Calculate structuring element radius
r=round(D/4);

%Create structuring element
S=strel('disk',r);

%Show structuring element
figure;
imshow(S.Neighborhood);
title(['Structuring Element (r = ' num2str(r) ')']);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question d~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Dilate hand
Idil=imdilate(Ibw, S);

%Show images
figure;
subplot(1,2,1);
imshow(Ibw);
title('Original Binary Image');

subplot(1,2,2);
imshow(Idil);
title('Dilated Binary Image');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question e~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Erode hand
Iero=imerode(Ibw, S);

%Show images
figure
subplot(1,2,1);
imshow(Ibw);
title('Original Binary Image');

subplot(1,2,2);
imshow(Iero);
title('Eroded Binary Image');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question f~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate edge portion
Iedge=Ibw&~imerode(Ibw, S);

%Show images
figure
subplot(1,2,1);
imshow(Ibw);
title('Original Binary Image');

subplot(1,2,2);
imshow(Iedge);
title('Edge Portion');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question g~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate proportion
edgeProp=sum(Iedge(:))/sum(Ibw(:));

%Show result
disp(['Proportion of hand within r of edge: ' num2str(edgeProp)]);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question h~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate outer region
Iout=~Ibw&(bwdist(Ibw)>D)&(bwdist(Ibw)<2*D);

%Create display image
Ihalo=Ibw|Iout;

%Show image
figure
imshow(Ihalo);
title('Hand with Halo');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question i~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Create masked image
Imask=Igray;
Imask(~Ibw)=0;

%Show image
figure
imshow(Imask);
title('Masked Grayscale Image');


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question j~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate average grayscale color of hand
avgColor=mean(Igray(Ibw));

%Show result
disp(['Average grayscale color of hand: ' num2str(avgColor)]);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Question k~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate gradient magnitude
[Gmag,~]=imgradient(Igray);

%Apply threshold
Iedge =Gmag>50; 			%This is just an example value, you need to adjust based on your own imageû

%Show image
figure
imshow(Iedge);
title('Edge of Hand');