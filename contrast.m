I = imread('data/2012-06- 9.jpg');
I2 = rgb2gray(I);
J1 = adapthisteq(I2);
J2 = histeq(I2);
%J3 = imadjust(I2, [0.22 0.41]); %neck values
%J3 = imadjust(I2, [0.33 0.58]); %body values
J3 = imadjust(I2, [0.5 0.58]); %detection values
figure;
imshow(J3);
figure;
imshowpair(I2,J3,'montage');
title('Original Image (left) and Contrast Enhanced Image (right)');
imshow(J2);

%test_cliplimit(I2);

function test_cliplimit(image)
    figure;
    subplot(1,5,1);imshow(image);title("Image initiale");
    for i = 1:1:3
        I = imadjust(image, [0.32 i/3.1]);
        subplot(1,4,i+1);imshow(I);title(["Image modifié : Sup = ", i/3.1] );
    end
   
end