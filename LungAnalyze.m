% Image Processing Toolbox Add-On
lungs_img = imread('test_lungs.jpg');

grayImg = rgb2gray(lungs_img);

edges = edge(grayImg, 'canny');

figure;
subplot(1, 2, 1);
imshow(grayImg);
title('Original Image');

subplot(1, 2, 2);
imshow(edges);
title('Edges Detected');

% imwrite(edges, 'lung_edges_result.jpg');
