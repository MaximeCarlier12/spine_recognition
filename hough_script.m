close all;
clear;

%load data
files = dir(fullfile('img_contrast','*.jpg'));
begin_spine = importdata('begin_spine_coordinates.txt', ',', 1);
end_spine = importdata('end_spine_coordinates.txt', ',', 1);
%% 

%loop for each image
for i = 1:30
    I = imread(strcat('img_contrast/',files(i).name));
    %I = rgb2gray(I);
    [M, N]=size(I);
    
    %crop image from top to bottom of spine
    I=I(begin_spine.data(i,1):end_spine.data(i,1),:,:);
    BW = edge(I,'canny',0.3);
    
    %hough transform calculation
    [H,T,R] = hough(BW);
    P  = houghpeaks(H,5);
    x = T(P(:,2)); y = R(P(:,1));
    
    %finding lines
    lines = houghlines(BW,T,R,P);
    figure, imshow(I), hold on
    max_len = 0;
    for k = 1:length(lines)
    % selecting vertical lines (>60 deg to horizontal axis)
       if lines(k).theta > -60 && lines(k).theta < 60
           xy = [lines(k).point1; lines(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
           % Plot beginnings and ends of lines
           plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
           % Determine the endpoints of the longest line segment
           len = norm(lines(k).point1 - lines(k).point2);
           if ( len > max_len)
              max_len = len;
              xy_long = xy;
           end
       end
    end
    saveas(i,strcat('hough/',files(i).name,'.jpg'));
end 

