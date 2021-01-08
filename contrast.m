%Img = imread('data/2012-06- 22.jpg');
%contrast_image(Img);

%% Création des images contrastées

files = dir(fullfile('data','*.jpg'));
%M_separation = zeros(30,2);
%M_end_spine = zeros(30,2);
%M_beg_spine = zeros(30,2);

for i = 1:1:30
    path_in = strcat('data/', files(i).name);
    Img = imread(path_in);
    [J, line_sup, line_inf] = contrast_image(Img);
    %M_separation(i,1) = line_sup;
    %M_separation(i,2) = line_inf;
    path_contr = strcat('img_contrast/', files(i).name);
    imwrite(J,path_contr);

%T = table(M_separation(:,1), M_separation(:,2), 'VariableNames', { 'lines_sup', 'lines_low'} );
%writetable(T, 'separation_coordinates.txt');
    Img = imread(path_contr);
    [J3, end_line, end_col] = end_boundary(Img, line_inf);
    %M_end_spine(i,1) = end_line;
    %M_end_spine(i,2) = end_col;
    path_out_end = strcat('img_end/', files(i).name);
    imwrite(J3,path_out_end);
    
    [J1, beg_line, beg_col] = beginning_boundary(Img, line_sup);
    %M_beg_spine(i,1) = beg_line;
    %M_beg_spine(i,2) = beg_col;
    path_out_begin = strcat('img_begin/', files(i).name);
    imwrite(J1,path_out_begin);
end
%T = table(M_end_spine(:,1), M_end_spine(:,2), 'VariableNames', { 'end_lines', 'end_columns'} );
%writetable(T, 'end_spine_coordinates.txt');
%T = table(M_beg_spine(:,1), M_beg_spine(:,2), 'VariableNames', { 'beg_lines', 'beg_columns'} );
%writetable(T, 'begin_spine_coordinates.txt');

%% Functions used

%% Detection of the boudaries of the spine = beginning
% Analyse des images résultats : la colonne identifiée est toujours bien
% placée. Les quelques images qui ne marchent pas bien car les dents
% blanches perturbent la bonne détection.

function[J1, beg_line, beg_column] = beginning_boundary(image, line_crop)
%coord_table = readtable('separation_coordinates.txt');
%coordinates = table2array(coord_table);
%im_path = ['img_contrast/2012-06-', ' ', int2str(num_image), '.jpg'];
I = image;
[m,n] = size(I);
I_begin = imcrop(I, [0 0 n line_crop]);
[m,n] = size(I_begin);
beg_line = 1;
beg_column = 1;
%[T,EM] = graythresh(I_begin);
%figure(1); imshow(I_begin)

skull_detect = false;
% detecter la ligne horizontale du haut de la colonne
for i = 1:m
    numBlackPixels = sum(I_begin(i,:) < 3)
    if (skull_detect == false) && (numBlackPixels < n*3/4)
        skull_detect = true;
    end
    if (skull_detect == true) && (numBlackPixels > n*8/10)
        beg_line = i
        break;
    end
end

%detecter la ligne verticale du haut de la colonne
min_black = m;
beg_column = 0;
for j = 1:n
    numBlackPixels = sum(I_begin(:,j) < 3);
    if numBlackPixels < min_black
        min_black = numBlackPixels;
        beg_column = j;
    end
end
beg_column
I_begin(beg_line-3:beg_line+3,:) = 120;
I_begin(:,beg_column-3:beg_column+3) = 120;
J1 = I_begin;
figure(3); imshow(J1) % afficher l'image avec le point de fin de la colonne

% subplot(2,2,1); imshow(edge(I_begin, 'Canny', [0.01 0.6], 3)); title('Canny');
% subplot(2,2,2); imshow(edge(I_begin, 'Canny', [0.02 0.5], 2)); title('Sobel');
% subplot(2,2,3); imshow(edge(I_begin, 'Sobel', 0.10)); title('Sobel');
% subplot(2,2,4); imshow(edge(I_begin, 'Sobel', 0.13)); title('Sobel');
% BW = edge(I_begin, 'Sobel', 0.10);

%[L,centers] = imsegkmeans(I_begin,2);
%L = watershed(L);
%D = bwdist(BW);
%B = labeloverlay(I_begin,L);
%imshow(B)
end

%% Detection of the boudaries of the spine = end
function [I_low, end_line, end_column] = end_boundary(image, line_crop)
%coord_table = readtable('separation_coordinates.txt');
%coordinates = table2array(coord_table);
%im_path = ['img_contrast/2012-06-', ' ', int2str(num_image), '.jpg'];
I = image;
[m,n] = size(I);
I_low = imcrop(I, [0 line_crop+1 n m-line_crop]);
[m,n] = size(I_low);
% On cherche la colonne la plus à gauche qui contient des pixels blancs
low_j = 2000;
low_i = 2000;
for j = n:-1:1
    numBlackPixels = sum(I_low(:, j) < 20);
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
end_line = low_i + line_crop;
end_column = low_j;
imshow(I_low) % afficher l'image avec le point de fin de la colonne
%imshowpair(I,I_low,'montage')
end

%% Comparison of different saturation thresholds
function cont(image)
    figure;
    subplot(1,5,1);imshow(image);title("Image initiale");
    for i = 1:1:3
        I = imadjust(image, [0.32 i/3.1]);
        subplot(1,4,i+1);imshow(I);title(["Image modifié : Sup = ", i/3.1] );
    end
   
end

%% Contrast the image with the linear transformation and saturation
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
%imshowpair(I2,J,'montage');
%imshow(J)
end