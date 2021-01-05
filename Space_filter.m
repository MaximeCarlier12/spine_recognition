image = rgb2gray(imread('SIFT_V1/contrasted_image1.png'));

figure;
subplot(1,4,1); imshow(image); title("Avant processing");
med_filtered_image = medfilt2(image, [4 4]);
subplot(1,4,2); imshow(med_filtered_image); title("filtre median 4x4");
gauss_filtered_image = imgaussfilt(image, 1);
subplot(1,4,3); imshow(gauss_filtered_image); title("filtre gaussien sigma = 1");
anisotropic_filtered_image = imdiffusefilt(image);
subplot(1,4,4); imshow(anisotropic_filtered_image); title("Anisotropic diffusion filter");

