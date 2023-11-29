% Lung CT Image Analyzer App

disp('Welcome to the Lung CT Image Analyzer App!');
disp('This app allows you to view and analyze lung CT images.');
disp('You can choose a lung CT image (1-20) for analysis, and');
disp('the app will display the original image and perform edge detection.');
disp('You can choose to continue analyzing more images or exit the app.');
disp("--------------------------------------------------------------------------------");

while true
    % Ask the user for the lung CT image number
    image_number = input('Enter the lung CT image number to view (1-20), or enter 0 to exit: ');

    % Check if the user wants to exit
    if image_number == 0
        disp('Exiting program.');
        break;  % Exit the while loop
    end

    % Validate the input
    if image_number < 1 || image_number > 20
        disp('Invalid input. Please enter a number between 1 and 20.');
        continue;  % Skip the rest of the loop and ask for input again
    end

    % Construct the image filename
    image_filename = sprintf('test_lungs_%02d.jpg', image_number);

    % Try to load the image
    try
        % Image Processing Toolbox Add-On
        lungs_img = imread(image_filename);

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
    catch
        % Catch any errors during image loading or processing
        disp('Error loading or processing the image. Please choose another image.');
        continue;  % Skip the rest of the loop and ask for input again
    end

    % Ask the user if they want to continue
    continue_choice = input('Do you want to generate another lung image? (yes/no): ', 's');

    if ~strcmpi(continue_choice, 'yes')
        disp('Exiting program.');
        break;  % Exit the while loop
    end
end

% Image Processing Toolbox Add-On

%% 
% Specify the folder where the files live.
myFolder = 'C:\Users\yourUserName\Documents\My Pictures';
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
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    % imageArray = imread(fullFileName);
    % imshow(imageArray);  % Display image.
    %drawnow; % Force display to update immediately.
    lungs_img = imread(fullFileName);
    edge_detections(lungs_img);
end

%% 
function edgeDe = edge_detections(lungs_img)
    grayImg = rgb2gray(lungs_img);
    
    %maybe this works
    %grayImg = lungs_img;

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


