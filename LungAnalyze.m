% % Lung CT Image Analyzer App
% 
% disp('Welcome to the Lung CT Image Analyzer App!');
% disp('This app allows you to view and analyze lung CT images.');
% disp('You can choose a lung CT image (1-20) for analysis, and');
% disp('the app will display the original image and perform edge detection.');
% disp('You can choose to continue analyzing more images or exit the app.');
% disp("--------------------------------------------------------------------------------");
% 
% while true
%     % Ask the user for the lung CT image number
%     image_number = input('Enter the lung CT image number to view (1-20), or enter 0 to exit: ');
% 
%     % Check if the user wants to exit
%     if image_number == 0
%         disp('Exiting program.');
%         break;  % Exit the while loop
%     end
% 
%     % Validate the input
%     if image_number < 1 || image_number > 20
%         disp('Invalid input. Please enter a number between 1 and 20.');
%         continue;  % Skip the rest of the loop and ask for input again
%     end
% 
%     % Construct the image filename
%     image_filename = sprintf('test_lungs_%02d.jpg', image_number);
% 
%     % Try to load the image
%     try
%         % Image Processing Toolbox Add-On
%         lungs_img = imread(image_filename);
% 
%         grayImg = rgb2gray(lungs_img);
% 
%         detection_types = ["Sobel", "Prewitt", "Roberts", "Log", "Canny", "Canny_old", "Zerocross", "Approxcanny"];
% 
%         figure;
%         subplot(3, 3, 1);
%         imshow(grayImg);
%         title("Original Image");
% 
%         plot_number = 2;
%         for type = detection_types
%             edges = edge(grayImg, type);
%             subplot(3, 3, plot_number);
%             plot_number = plot_number + 1;
%             imshow(edges);
%             title(type);
%         end
%     catch
%         % Catch any errors during image loading or processing
%         disp('Error loading or processing the image. Please choose another image.');
%         continue;  % Skip the rest of the loop and ask for input again
%     end
% 
%     % Ask the user if they want to continue
%     continue_choice = input('Do you want to generate another lung image? (yes/no): ', 's');
% 
%     if ~strcmpi(continue_choice, 'yes')
%         disp('Exiting program.');
%         break;  % Exit the while loop
%     end
% end
% 
% % Image Processing Toolbox Add-On

%% 
% Specify the folder where the files live.
myFolder = 'samples';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.png'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
close all;
itemNames = cell(length(theFiles));
fileNames = cell(length(theFiles));
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    
    fullFileName = fullfile(theFiles(k).folder, baseFileName);

    itemNames(k) = {[baseFileName ' 50% likely to have mass']};
    fileNames(k) = {fullFileName};

    fprintf(1, 'Now reading %s\n', fullFileName);
    disp(fullFileName);
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    lungs_img = imread(fullFileName);

    %TODO: SORT ItemNames from most to least
end
%%
% Create a figure
fig = figure('Name', 'GUI', 'units', 'normalized', 'Position', [0.2, 0.2, 0.6, 0.6]);

% Create a listbox
listbox = uicontrol('Style', 'listbox', 'units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8], 'String', itemNames, 'UserData', fileNames, 'Callback', @listboxCallback);

% Callback function for listbox selection
function listboxCallback(src, event)
    % Get the selected item from the listbox
    index = get(src, 'Value');
    items = get(src, 'String');
    UserData = get(src, 'UserData');
    selected_item = items{index};
    filename = UserData{index};
    disp(filename);
    fprintf(1, 'Now reading %s\n', filename);
    lungs_img = imread(filename);
    find_circles(lungs_img, selected_item, [0.22 0.6], 0.84, [0.21 0.55], 0.88);
end


%%
function find_circles(img, img_name, intensity_bw, circle_sens_bw, intensity_edge, circle_sens_edge)
    % find_circles  tries to detect circles in the img based on the provided
    % thresholds
    %   find_circles(img, [min_in max_in], circle_sens) adjusts img contrast
    %   based on [min_in max_in] and detects circles based on circle_sens
    % Inputs:
    %   img         : the image to detect circles in
    %   intensity   : [min = 0...1 max = 0...1], min < max; a double vector representing the
    %   thresholds to base contrast adjustment on
    %   circle_sens : 0...1; the threshold for circle detection. Greater values
    %   are less sensitive
    %   method      : the filter to use circle detection on
    arguments
      img
      img_name
      intensity_bw (1,2) double = [0.2 0.6]
      circle_sens_bw double {mustBeInRange(circle_sens_bw,0,1)} = 0.85
      intensity_edge (1,2) double = [0.2 0.6]
      circle_sens_edge double {mustBeInRange(circle_sens_edge,0,1)} = 0.85
    end
    figure('Name', img_name);
    set(gcf, 'Position',  [360, 360, 1280, 540]);
    subplot(1,3,1);
    imshow(img);
    title("Original");

    img = im2gray(img);

    % detect circles
    % method = 'bw';
    img_adjusted_bw = imadjust(img, intensity_bw);
    subplot(1,3,2);
    %     imshow(img_adjusted)
    %     title("Contrast Adjusted");
        
    img_BW = imbinarize(img_adjusted_bw);
    imshow(img_adjusted_bw)
    title("Contrast adjusted");
    [centers, radii] = imfindcircles(img_BW,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_bw);
    if not(isempty(centers))
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        radiiStrong5 = radii(1:max_len);
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
    else
        disp("No circles found.");
    end
    
    % method = 'edge';
    img_adjusted_edge = imadjust(img, intensity_edge);
    subplot(1,3,3);
        
    img_BW = imbinarize(img_adjusted_edge);
    edges = edge(img_BW, 'canny');
    imshow(edges)
    title("Edge detection");
    [centers, radii] = imfindcircles(edges,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_edge);
    
    if not(isempty(centers))
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        radiiStrong5 = radii(1:max_len);
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','r');
    else
        disp("No circles found.");
    end

end

%% 
function edgeDe = edge_detections(lungs_img)
    grayImg = im2gray(lungs_img);

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
end