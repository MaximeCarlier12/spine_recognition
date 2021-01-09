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

thresh = -20;
for i = 3:1:3
    I = imread(strcat('img_contrast/', files(i).name));
    [M N] = size(I);
    corners = detectHarrisFeatures(I, 'MinQuality', 0.01); %param à déterminer, plus il est élevé moins on a de points
    [features, valid_corners] = extractFeatures(I, corners);

    figure; imshow(I); hold on
    plot(valid_corners); hold off

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
    interesting_points = [begin_spine.data(i, 2) begin_spine.data(i, 1)];
    i
    for x = 1:1:m
        if (sorted_round_tab(x, 2) > begin_spine.data(i,1)) && (sorted_round_tab(x, 2) < end_spine.data(i,1)) && sorted_round_tab(x, 1) > 0.4*N % If we are between the beginning and the end of the spine
            if sorted_round_tab(x, 1) - interesting_points(count, 1) > thresh    
                if sorted_round_tab(x, 2) == tmp(2) % if on the same line
                    if sorted_round_tab(x, 1) > tmp(1) % check if new point is more on the right
                        if interesting_points(count, 2) ~= sorted_round_tab(x, 2)
                            tmp = sorted_round_tab(x,:);
                            count = count + 1;
                        end
                        interesting_points(count, :) = sorted_round_tab(x,:);
                    end
                end
                count = count + 1;
                interesting_points(count, :) = tmp; 
            end
            tmp= sorted_round_tab(x, :);
        end
    end
    figure(i); imshow(I); title(files(i).name); hold on
    [o p] = size(interesting_points);
    plot(begin_spine.data(i,2), begin_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); %plot begining spine
    plot(end_spine.data(i,2), end_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); % plot end spine
    for j = 1:1:o
        plot(interesting_points(j, 1), interesting_points(j, 2), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    end
    hold off
    a = "image suivante"
end    

%% Harris selection points from right side
for i = 5:1:5
    I = imread(strcat('img_contrast/', files(i).name));
    [M N] = size(I);
    corners = detectHarrisFeatures(I, 'MinQuality', 0.01); %param à déterminer, plus il est élevé moins on a de points
    [features, valid_corners] = extractFeatures(I, corners);

%     figure; imshow(I); hold on
%     plot(valid_corners); hold off

    % ### FINDING THE POINTS ON THE VEY RIGHT DELIMITATION ###
    %       Sorting our keypoints by their value along the y axis
    [~,idx] = sort(valid_corners.Location(:,2)); % 
    sorted_tab = valid_corners.Location(idx,:);   % sort the whole matrix using the sort indices
    sorted_round_tab = round(sorted_tab);
    
    for y=begin_spine.data(i,1):1:end_spine.data(i,1) % we go through all the lines between top and end of the spine
        for x=N:-1:1
            if I(y,x) > 1
                body_right_part(y) = x;
                break
            end
        end
    end
    body_right_part = body_right_part.';
    % PLOT OF THE DETECTED POINTS ON THE RIGHT PART OF THE BODY
    figure; imshow(I); title('Right POINTS'); hold on
    plot(begin_spine.data(i,2), begin_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); %plot begining spine
    plot(end_spine.data(i,2), end_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); % plot end spine
    [a d] = size(body_right_part);
    for z = 1:1:d
        if body_right_part(z) ~= 0
            plot(body_right_part(z), z, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
        end
    end
   hold off

    % ### SELECTING IN THE KEY POINTS THE ONES IN THE AREA OF THE POINTS ON
    % THE RIGHT PART OF THE BODY
    count = 1;
    interesting_points = [0 0];
    for l=begin_spine.data(i,1):1:end_spine.data(i,1)
        indice = sorted_round_tab(:,2) == body_right_part(l);
        sub_tab = sorted_round_tab(indice,:);
        for k=1:1:size(sub_tab(:,1)) % sur une même ligne
            if sub_tab(k,1) > (body_right_part(l)-10)
                interesting_points(count, :) = sub_tab(k,:);
                count = count+1;
            end
        end
    end
    
    figure; imshow(I); hold on
    [o p] = size(interesting_points);
    plot(begin_spine.data(i,2), begin_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); %plot begining spine
    plot(end_spine.data(i,2), end_spine.data(i,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); % plot end spine
    for j = 1:1:o
        plot(interesting_points(j, 1), interesting_points(j, 2), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    end
    hold off
end