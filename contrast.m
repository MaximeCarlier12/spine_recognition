%Img = imread('data/2012-06- 22.jpg');
%contrast_image(Img);

%% Création des images contrastées

files = dir(fullfile('data','*.jpg'));
M_separation = zeros(30,2);
M_end_spine = zeros(30,2);

for i = 1:1:30
    path_in = strcat('data/', files(i).name);
    Img = imread(path_in);
    [J, x_sup, x_low] = contrast_image(Img);
    M_separation(i, 1) = x_sup;
    M_separation(i,2) = x_low;
    path_out = strcat('img_contrast/', files(i).name);
    [J3, end_x, end_y] = end_boundary(i);
    M_end_spine(i,1) = end_x;
    M_end_spine(i,2) = end_y;
    imwrite(J,path_out);
end

T = table(M_separation(:,1), M_separation(:,2), 'VariableNames', { 'x_sup', 'x_low'} );
writetable(T, 'separation_coordinates.txt');
T = table(M_end_spine(:,1), M_end_spine(:,2), 'VariableNames', { 'end_x', 'end_y'} );
writetable(T, 'end_spine_coordinates.txt');

%% Detection of the boudaries of the spine = beginning
num_image = 9;
im_path = ['img_contrast/2012-06-', ' ', int2str(num_image), '.jpg'];
coord_table = readtable('separation_coordinates.txt');
coordinates = table2array(coord_table);
I = imread(im_path);
[m,n] = size(I);
I_begin = imcrop(I, [0 0 n m-coordinates(num_image,1)]);
[m,n] = size(I_begin);
low_j = 2000;
low_i = 2000;
imshow(edge(I_begin, 'Sobel', 0.07)); title('Sobel');

%% Pour une seule image

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

%% Functions used

% Detection of the boudaries of the spine = end
function [I_low, low_i, low_j] = end_boundary(num_image)
coord_table = readtable('separation_coordinates.txt');
coordinates = table2array(coord_table);
im_path = ['img_contrast/2012-06-', ' ', int2str(num_image), '.jpg'];
I = imread(im_path);
[m,n] = size(I);
I_low = imcrop(I, [0 coordinates(num_image,2)+1 n m-coordinates(num_image,2)]);
[m,n] = size(I_low);
% On cherche la colonne la plus à gauche qui contient des pixels blancs
low_j = 2000;
low_i = 2000;
for j = n:-1:1
    numBlackPixels = sum(I_low(:, j) < 20)
    if numBlackPixels < m*7/10
        low_j = j
        break;
    end
end
% On cherche la ligne où sur la colonne trouvée ci-dessus, 1/3 des pixels
% blancs sont en dessous de cette ligne.
count = 0;
for i = m:-1:1
    if I_low(i, low_j) > 20
        count = count +1;
    end
    if count > sum(I_low(:,low_j)>20)*1/3 % ou 1/4
        low_i = i
        break;
    end
end
I_low(low_i-3:low_i+3,:) = 255;
I_low(:,low_j-3:low_j+3) = 255;
imshow(I_low)
%imshowpair(I,I_low,'montage')
end

%Comparison of different saturation thresholds
function cont(image)
    figure;
    subplot(1,5,1);imshow(image);title("Image initiale");
    for i = 1:1:3
        I = imadjust(image, [0.32 i/3.1]);
        subplot(1,4,i+1);imshow(I);title(["Image modifié : Sup = ", i/3.1] );
    end
   
end

% Contrast the image with the linear transformation and saturation
function [J, x1, x2] = contrast_image(image)

I = image;
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
imshowpair(I2,J,'montage');
%imshow(J)
end