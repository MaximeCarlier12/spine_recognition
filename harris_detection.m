%% loadind data
files = dir(fullfile('img_contrast','*.jpg'));
begin_spine = importdata('begin_spine_coordinates.txt', ',', 1);
end_spine = importdata('end_spine_coordinates.txt', ',', 1);

%% Harris selection points from right side
errors = 0;
for i = 1:30
    num_image = i;
    I = imread(strcat('img_contrast/', files(num_image).name));
    [M N] = size(I);
    corners = detectHarrisFeatures(I, 'MinQuality', 0.005); %param à déterminer, plus il est élevé moins on a de points
    [features, valid_corners] = extractFeatures(I, corners);
    % trier tableau de key points de harris par lignes croissantes
    [~,idx] = sort(valid_corners.Location(:,2)); % 
    sorted_tab = valid_corners.Location(idx,:);   % sort the whole matrix using the sort indices
    sorted_round_tab = round(sorted_tab);

    % trouver les points les plus à droite de chaque ligne
    threshold_intensity = 80;
    for y=begin_spine.data(num_image,1):1:end_spine.data(num_image,1) % we go through all the lines between top and end of the spine
            for x=N:-1:1
                if I(y,x) > threshold_intensity
                    body_right_part(y) = x;
                    break
                end
            end
    end
    body_right_part = body_right_part.';
    % SELECTING IN THE KEY POINTS THE ONES IN THE AREA OF THE POINTS ON THE RIGHT PART OF THE BODY
    interesting_points = [begin_spine.data(num_image,2) begin_spine.data(num_image,1)];
    count = 2;
    pixel_interval = 200; %400;
    scale_left = 10;
    for line=begin_spine.data(num_image,1):1:end_spine.data(num_image,1)
        % indices : pour chaque key_points, il y a un 1 si elle est à cette
        % ligne. 
        indices = sorted_round_tab(:,2) == line;
        sub_tab = sorted_round_tab(indices,:);
        cond1 = sub_tab(:,1) > (body_right_part(line)-pixel_interval);
        cond2 = sub_tab(:,1) < (body_right_part(line)-scale_left);
        condition = and(cond1, cond2);
        mini_tab = sub_tab(condition, :);
        if not(isempty(mini_tab))
            interesting_points(count, 1) = mean(mini_tab(:, 1));
            interesting_points(count, 2) = mini_tab(1, 2);
            count = count +1;
        end
    end 
    interesting_points(count, :) = [end_spine.data(num_image,2) end_spine.data(num_image,1)];
    % on retire les points dont l'abscisse est dans le premier tiers de l'image
    condition = interesting_points(:,1) > 0.3*N;
    interesting_points = interesting_points(condition, :);
    [m_int n_int] = size(interesting_points);
    figure(i);
    imshow(I);
    hold on;
    title(files(num_image).name);
    plot(begin_spine.data(num_image,2), begin_spine.data(num_image,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); %plot begining spine
    plot(end_spine.data(num_image,2), end_spine.data(num_image,1), 'g+', 'MarkerSize', 5, 'LineWidth', 2); % plot end spine
    number_points = m_int;
    for point = 1:number_points
        plot(interesting_points(point, 1), interesting_points(point, 2), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
    end
    size(interesting_points)
    % polyfit
    if m_int > 800
        degree = min(8,round(m_int/100));
    else
        degree = max(4, round(m_int/70));
    end
    
    x1 = interesting_points(:,2);
    %x1 = linspace(begin_spine.data(num_image,1), end_spine.data(num_image,1));
    
    p = polyfit(interesting_points(:,2),interesting_points(:,1), degree);
    y1 = polyval(p,x1);
    LSE = 0;
    fitpoints = [y1 x1];
    for point = 1:number_points
        LSE = LSE + norm(interesting_points(point,:)-fitpoints(point,:));
    end

    plot(y1,x1,'Color', 'b', 'LineWidth',4) % afficher courbe.
    hold off;

    % l'erreur par point est de...
    err = LSE/number_points
    errors(i)=err;
    path_harris = strcat('img_harris/', files(num_image).name);
    saveas(gcf, path_harris);
end

%% Visualize all key points
figure(31);
imshow(I);
hold on;
plot(valid_corners); hold off
hold off;