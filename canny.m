close all;
clear;

files = dir(fullfile('img_contrast','*.jpg'));
begin_spine = importdata('begin_spine_coordinates.txt', ',', 1);
end_spine = importdata('end_spine_coordinates.txt', ',', 1);
%% 

for i = 1:30
    I = imread(strcat('img_contrast/',files(i).name));
    %I = rgb2gray(I);
    [M, N]=size(I);
    I=I(begin_spine.data(i,1):end_spine.data(i,1),:,:);
    BW = edge(I,'canny',0.3);
    imwrite(BW,strcat('canny/',files(i).name));
end 
