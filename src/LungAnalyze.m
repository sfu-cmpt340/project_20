%% Find folder files and check images
% Specify the folder where the files live [samples,samples-normal].
myFolder = 'samples';

% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Please specify a new folder.\nTo use the provided sample folder, please use samples for samples with mass, or use samples-normal without mass', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir('src'); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.png'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
close all;
itemNames = cell(0);
fileNames = cell(0);
circlePercentage = zeros(0);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    
    fullFileName = fullfile(theFiles(k).folder, baseFileName);


    fprintf(1, 'Now reading %s\n', fullFileName);
    disp(fullFileName);
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    lungs_img = imread(fullFileName);
    num_of_circles = check_circles(lungs_img, [0.22 0.6], 0.84, [0.21 0.55], 0.88);
    imgPercent = round(num_of_circles/ (25+(k/10)), 4);

    circlePercentage(k) = imgPercent;
    itemNames(k) = {[baseFileName ' ' num2str(imgPercent*100) '% likely to have mass']};
    fileNames(k) = {fullFileName};
end

[~, sortedIndices] = sort(circlePercentage, 'descend');

itemNames = itemNames(sortedIndices);
fileNames = fileNames(sortedIndices);
circlePercentage = circlePercentage(sortedIndices);


%% Creating the GUI
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
    if(not(isempty(filename)))
        lungs_img = imread(filename);
        find_circles(lungs_img, selected_item, [0.22 0.6], 0.84, [0.21 0.55], 0.88);
    end

end


%% Function to show circles GUI
function [num_of_circles] = find_circles(img, img_name, intensity_bw, circle_sens_bw, intensity_edge, circle_sens_edge)
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


    img_adjusted_bw = imadjust(img, intensity_bw);
    subplot(1,3,2);

        
    img_BW = imbinarize(img_adjusted_bw);
    imshow(img_adjusted_bw)
    title("Contrast adjusted");
    num_of_circles = 0;
    [centers, radii] = imfindcircles(img_BW,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_bw);
    if not(isempty(centers))
        num_of_circles = num_of_circles + length(centers);
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        radiiStrong5 = radii(1:max_len);
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
    else
        disp("No circles found.");
    end
    
    img_adjusted_edge = imadjust(img, intensity_edge);
    subplot(1,3,3);
        
    img_BW = imbinarize(img_adjusted_edge);
    edges = edge(img_BW, 'canny');
    imshow(edges)
    title("Edge detection");
    [centers, radii] = imfindcircles(edges,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_edge);
    
    if not(isempty(centers))
        num_of_circles = num_of_circles + length(centers);
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        radiiStrong5 = radii(1:max_len);
        viscircles(centersStrong5, radiiStrong5,'EdgeColor','r');
        
    else
        disp("No circles found.");
    end
end
%% Function to check for circles
function [num_of_circles] = check_circles(img, intensity_bw, circle_sens_bw, intensity_edge, circle_sens_edge)
    arguments
      img
      intensity_bw (1,2) double = [0.2 0.6]
      circle_sens_bw double {mustBeInRange(circle_sens_bw,0,1)} = 0.85
      intensity_edge (1,2) double = [0.2 0.6]
      circle_sens_edge double {mustBeInRange(circle_sens_edge,0,1)} = 0.85
    end

    img = im2gray(img);

    img_adjusted_bw = imadjust(img, intensity_bw);
        
    img_BW = imbinarize(img_adjusted_bw);

    num_of_circles = 0;
    [centers, radii] = imfindcircles(img_BW,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_bw);
    if not(isempty(centers))
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        num_of_circles = num_of_circles + length(centersStrong5);
    end
    
    img_adjusted_edge = imadjust(img, intensity_edge);

    img_BW = imbinarize(img_adjusted_edge);
    edges = edge(img_BW, 'canny');
    [centers, radii] = imfindcircles(edges,[9 50], 'ObjectPolarity','bright', 'Sensitivity', circle_sens_edge);
    
    if not(isempty(centers))
        max_len = min([length(radii) 3]); % only display up to the x strongest circles
        centersStrong5 = centers(1:max_len,:); 
        num_of_circles = num_of_circles + length(centersStrong5);
    end
end
