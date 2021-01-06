I = imread('data/2012-06- 22.jpg');
I2 = rgb2gray(I);
J1 = adapthisteq(I2);
J2 = histeq(I2);
J3A = imadjust(I2, [0.22 0.41]); %neck values
J3B = imadjust(I2, [0.42 0.58]); %body values
J3C = imadjust(I2, [0.45 0.98]); %pelvis values
D1 = imadjust(I2, [0.5 0.58]); %detection values 1
D2 = imadjust(I2, [0.45 0.88]); %detection values 2
%figure;
%imshowpair(I2,D1,'montage');
%title('Original Image (left) and Contrast Enhanced Image (right)');
%imshow(J2);
[m,n] = size(I2);
x1 = 1000;
x2 = 2000;

for i = 1:1:m
    numBlackPixels = sum(D1(i,:) < 5);
    if numBlackPixels < n*3/4
        x1 = i
        break;
    end
end

for i = 1:1:m
    numBlackPixels2 = sum(D2(i,:) < 5);
    if numBlackPixels2 < n/2
        x2 = i
        break;
    end
end

J3A = imcrop(J3A, [0 0 n x1]);
J3B = imcrop(J3B, [0 x1+1 n x2-x1]);
J3C = imcrop(J3C, [0 x2+1 n m-x2]);
J = cat(1,J3A,J3B,J3C);
%imshowpair(I2,J,'montage');
imshow(J)

%cont(I2);

function cont(image)
    figure;
    subplot(1,5,1);imshow(image);title("Image initiale");
    for i = 1:1:3
        I = imadjust(image, [0.32 i/3.1]);
        subplot(1,4,i+1);imshow(I);title(["Image modifié : Sup = ", i/3.1] );
    end
   
end