
list_im = dir('data/*.jpg');

%contrast_image(list_im);


image1 = rgb2gray(imread('data/test.jpg'));
image2 = rgb2gray(imread('data/2012-06- 4.jpg'));
%test_cliplimit(image1);
%test_distribution(image2);



function contrast_image(list_im)

    for i = 1:length(list_im)
        figure;
        images_namei = list_im(i).name;
        imagei = rgb2gray(imread(strcat('data/',images_namei)));
        J = adapthisteq(imagei);
        subplot(2,1,1);imshow(imagei);title("Image initiale"); 
        subplot(2,1,2);imshow(J);title("Image contrasté"); 
    end

end

function test_cliplimit(image)
    figure;
    %subplot(2,4,1);imshow(image);title("Image initiale");
    for i = 1:1:8
        I = adapthisteq(image,'Distribution','uniform','Nbins',2^i);
        subplot(2,4,i);imshow(I);title(["Image modifié : Nbins = ", 2^i] );
    end

end

function test_distribution(image)

    
    figure;
    subplot(1,4,1);imshow(image);title("Image initiale");
    I = adapthisteq(image,'Distribution','uniform');
    subplot(1,4,2);imshow(I);title("Image modifié : Uniform" );
    I = adapthisteq(image,'Distribution','rayleigh');
    subplot(1,4,3);imshow(I);title("Image modifié : rayleigh" );
    I = adapthisteq(image,'Distribution','exponential');
    subplot(1,4,4);imshow(I);title("Image modifié : exponential" );
end
