
%Img = imread('data/2012-06- 22.jpg');
%contrast_image(Img);

%% Création des images contrastées et calcul de début et fin de la colonne.
clear;
files = dir(fullfile('data','*.jpg'));
M_separation = zeros(30,2);
M_end_spine = zeros(30,2);
M_beg_spine = zeros(30,2);

for i = 1:1:30
    path_in = strcat('data/', files(i).name);
    Img = imread(path_in);
    [J, line_sup, line_inf] = contrast_image(Img);
    M_separation(i,1) = line_sup;
    M_separation(i,2) = line_inf;
    path_contr = strcat('img_contrast/', files(i).name);
    imwrite(J,path_contr);
end
T = table(M_separation(:,1), M_separation(:,2), 'VariableNames', { 'lines_sup', 'lines_inf'} );
writetable(T, 'separation_coordinates.txt');
%%
coord_table = readtable('separation_coordinates.txt');
coordinates = table2array(coord_table);
for i = 1:1:30
    path_contr = strcat('img_contrast/', files(i).name);
    Img = imread(path_contr);
    line_inf = coordinates(i, 2);
    [J3, end_line, end_col] = end_boundary(Img, line_inf);
    M_end_spine(i,1) = end_line;
    M_end_spine(i,2) = end_col;

    path_out_end = strcat('img_end/', files(i).name);
    imwrite(J3,path_out_end);
    
    [J1, beg_line, beg_col] = beginning_boundary(Img, line_sup);
    M_beg_spine(i,1) = beg_line;
    M_beg_spine(i,2) = beg_col;
    path_out_begin = strcat('img_begin/', files(i).name);
    imwrite(J1,path_out_begin);
end
T = table(M_end_spine(:,1), M_end_spine(:,2), 'VariableNames', { 'end_lines', 'end_columns'} );
writetable(T, 'end_spine_coordinates.txt');
T = table(M_beg_spine(:,1), M_beg_spine(:,2), 'VariableNames', { 'beg_lines', 'beg_columns'} );
writetable(T, 'begin_spine_coordinates.txt');


%% Functions used

%% Test of coordinates files.
function[files] = test_coordinates_files()
    coord_beg = readtable('begin_spine_coordinates.txt');
    coord_beg = table2array(coord_beg);
    coord_end = readtable('end_spine_coordinates.txt');
    coord_end = table2array(coord_end);
    files = dir(fullfile('data','*.jpg'));
    for i = 1:1:30
        path_contr = strcat('img_contrast/', files(i).name);
        Img = imread(path_contr);
        figure(i);
        imshow(Img); hold on 
        title(files(i).name);
        plot(coord_beg(i, 2), coord_beg(i,1), 'r+');
        plot(coord_end(i, 2), coord_end(i,1), 'r+'); hold off
    end
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

% %% Contrast the image with the linear transformation and saturation
% function [J, x1, x2] = contrast_image_func(image)
% 
% I = image;
% I2 = rgb2gray(I);
% J1 = adapthisteq(I2);
% J2 = histeq(I2);
% J3A = imadjust(I2, [0.22 0.41]); %neck values
% J3B = imadjust(I2, [0.42 0.58]); %body values
% J3C = imadjust(I2, [0.45 0.98]); %pelvis values
% D1 = imadjust(I2, [0.5 0.58]); %detection values 1
% D2 = imadjust(I2, [0.45 0.88]); %detection values 2
% %figure;
% %imshowpair(I2,D1,'montage');
% %title('Original Image (left) and Contrast Enhanced Image (right)');
% %imshow(J2);
% [m,n] = size(I2);
% x1 = 1000;
% x2 = 2000;
% 
% for i = 1:1:m
%     numBlackPixels = sum(D1(i,:) < 5);
%     if numBlackPixels < n*3/4
%         x1 = i
%         break;
%     end
% end
% 
% for i = 1:1:m
%     numBlackPixels2 = sum(D2(i,:) < 5);
%     if numBlackPixels2 < n/2
%         x2 = i
%         break;
%     end
% end
% 
% J3A = imcrop(J3A, [0 0 n x1]);
% J3B = imcrop(J3B, [0 x1+1 n x2-x1]);
% J3C = imcrop(J3C, [0 x2+1 n m-x2]);
% J = cat(1,J3A,J3B,J3C);
% %imshowpair(I2,J,'montage');
% %imshow(J)
% end