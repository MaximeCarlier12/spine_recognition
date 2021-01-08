I = imread('img_contrast/2012-06- 1.jpg');

%% SURF Features
points = detectSURFFeatures(I);
[features,validPoints] = extractFeatures(I,points)
figure; imshow(I); hold on;
plot(points.selectStrongest(10)); hold off

%% loadind data
files = dir(fullfile('img_contrast','*.jpg'));
begin_spine = importdata('begin_spine_coordinates.txt', ',', 1);
end_spine = importdata('end_spine_coordinates.txt', ',', 1);

%% Harris features

thresh = 150;
for i = 1:1:1
    I = imread(strcat('img_contrast/', files(i).name));
    [M N] = size(I);
    corners = detectHarrisFeatures(I, 'MinQuality', 0.011); %param à déterminer, plus il est élevé moins on a de points
    [features, valid_corners] = extractFeatures(I, corners);

    % figure; imshow(I); hold on
    % plot(valid_corners); hold off

    % ### Selection of the points of interests ###
    %       Sorting our keypoints by their value along the y axis
    [~,idx] = sort(valid_corners.Location(:,2)); % sort just the first column
    sorted_tab = valid_corners.Location(idx,:);   % sort the whole matrix using the sort indices
    %       Removing all the points that are not between the beginning and end
    %       of the spine
    [m, n] = size(sorted_tab);
    sorted_round_tab = round(sorted_tab);
    count = 1;
    tmp = [begin_spine.data(i,2) 0];
    interesting_points = [0 0];
    for x = 1:1:m
        if (sorted_round_tab(x, 2) > begin_spine.data(i,1)) && (sorted_round_tab(x, 2) < end_spine.data(i,1)) && sorted_round_tab(x, 1) > 0.3*M % If we are between the beginning and the end of the spine
            if sorted_round_tab(x, 2) == tmp(2)
                if sorted_round_tab(x, 1) > tmp(1)
                    %tmp = sorted_round_tab(x,:);
                    %count = count + 1;
                    interesting_points(count, :) = tmp; 
                end
            else
                if abs(sorted_round_tab(x, 1) - tmp(1)) < thresh
                    a = 1
                    %tmp = sorted_round_tab(x, :);
                    interesting_points(count, :) = tmp; 
                    count = count + 1;
                end
            end
            tmp= sorted_round_tab(x, :);
        end
    end
    figure; imshow(I); hold on
    [o p] = size(interesting_points)
    plot(begin_spine.data(i,2), begin_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2);
    plot(end_spine.data(i,2), end_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2);
    for j = 1:1:o
        plot(interesting_points(j, 1), interesting_points(j, 2), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    end
end    
