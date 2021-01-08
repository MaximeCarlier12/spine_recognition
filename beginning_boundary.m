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
% figure(3); imshow(J1) % afficher l'image avec le point de fin de la colonne

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
