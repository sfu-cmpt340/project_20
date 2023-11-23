% Image Processing Toolbox Add-On
lungs_img = imread("test_lungs.jpg");

grayImg = rgb2gray(lungs_img);

detection_types = ["Sobel", "Prewitt", "Roberts", "Log", "Canny", "Canny_old", "Zerocross", "Approxcanny"];

figure;
subplot(3, 3, 1);
imshow(grayImg);
title("Original Image");

plot_number = 2;
for type = detection_types
    edges = edge(grayImg, type);
    subplot(3, 3, plot_number);
    plot_number = plot_number + 1;
    imshow(edges);
    title(type);
end


% imwrite(edges, "lung_edges_result.jpg");
