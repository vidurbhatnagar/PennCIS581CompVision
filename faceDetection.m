%Training Phase for SVM
trainingfolder = 'trainsetfacedetection/';
traininglist = dir(trainingfolder);
traininglist = traininglist(3:end,:);
HOGDesc = [];

%Configurations for the HOG features
numBins = 9;
signed = 0;
cellSize = [8 8];
blockSize = [24 24];
windowSize = [64 64];

%Loading Images and Getting HOG
for i=1:size(traininglist)
    imgName = strcat(trainingfolder,traininglist(i).name)
    disp('Getting Hog For image');
    disp(imgName);
    img = imread(imgName);
    img = imresize(img,windowSize);
    imggray = rgb2gray(img);
    imggray = im2double(imggray);
    hogDescForImg = getHOGWrapper(imggray,numBins,signed,cellSize,blockSize);
    %hogDescForImg = extractHOGFeatures(imggray);
    HOGDesc = [HOGDesc; hogDescForImg'];
end
Xtrain = HOGDesc;
negLabels = zeros(1218,1);
posLabels = ones(2000,1);
labels = [negLabels; posLabels]; 
Ytrain = labels;
[genError meanAcc best_model heldOutAccBest_model full_model heldOutAccFull_model] = cross_validation(@svmrun, Xtrain, Ytrain, 10);

% Testing an image
img = imread('image_hog.jpg');
imggray = rgb2gray(img);
imggray = im2double(imggray);

% Bouning Boxes for Faces
boundingBoxes = detectface(imggray, windowSize, numBins, signed, cellSize, blockSize, full_model);
for i=1:size(boundingBoxes)
    ann_img = insertObjectAnnotation(img,'rectangle',boundingBoxes(i,:),'Face');
    imshow(ann_img);
    pause;
end
