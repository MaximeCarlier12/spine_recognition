image1 = rgb2gray(imread('data/test.jpg'));
image2 = rgb2gray(imread('data/2012-06- 4.jpg'));

figure;
constrasted_image1 = adapthisteq(image1,'Distribution','uniform','Nbins',256);
imshow(constrasted_image1);
saveas(gcf,'constrasted_image1.png')

figure;
constrasted_image2 = adapthisteq(image2,'Distribution','uniform','Nbins',256);
imshow(constrasted_image2);
saveas(gcf,'constrasted_image2.png')