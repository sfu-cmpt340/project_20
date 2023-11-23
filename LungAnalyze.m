% Image Processing Toolbox Add-On
lungs_img = imread('test_lungs.jpg');

grayImg = rgb2gray(lungs_img);


figure;
subplot(3, 3, 1);
imshow(grayImg);
title('Original Image');

edges2 = edge(grayImg, 'sobel');

subplot(3, 3, 2);
imshow(edges2);
title('Edges Detected Sobel');

edges3 = edge(grayImg, 'prewitt');

subplot(3, 3, 3);
imshow(edges3);
title('Edges Detected prewitt');

edges4 = edge(grayImg, 'roberts');

subplot(3, 3, 4);
imshow(edges4);
title('Edges Detected roberts');

edges5 = edge(grayImg, 'log');

subplot(3, 3, 5);
imshow(edges5);
title('Edges Detected log');

edges6 = edge(grayImg, 'canny');

subplot(3, 3, 6);
imshow(edges6);
title('Edges Detected canny');

edges7 = edge(grayImg, 'canny_old');

subplot(3, 3, 7);
imshow(edges7);
title('Edges Detected canny_old');

edges8 = edge(grayImg, 'zerocross');

subplot(3, 3, 8);
imshow(edges8);
title('Edges Detected zerocross');

edges9 = edge(grayImg, 'approxcanny');
subplot(3, 3, 9);
imshow(edges9);
title('Edges Detected approxcanny');

% imwrite(edges, 'lung_edges_result.jpg');
