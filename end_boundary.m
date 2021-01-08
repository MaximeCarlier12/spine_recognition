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
% imshow(I_low) % afficher l'image avec le point de fin de la colonne
%imshowpair(I,I_low,'montage')
end
