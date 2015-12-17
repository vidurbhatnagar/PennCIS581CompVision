%Training Phase for SVM
trainingposfolder = 'trainsetpositive/';
trainingposlist = dir(trainingposfolder);
trainingposlist = trainingposlist(3:end,:);

trainingnegfolder = 'trainsetnegative/';
trainingneglist = dir(trainingnegfolder);
trainingneglist = trainingneglist(3:end,:);

traininglist = [trainingposlist; trainingneglist];
trainingfolder = repmat({trainingposfolder}, [size(trainingposlist,1) 1]);
trainingfolder = [trainingfolder ; repmat({trainingnegfolder}, [size(trainingneglist,1) 1])];

posLabels = ones(size(trainingposlist,1),1);
negLabels = zeros(size(trainingneglist,1),1);
labels = [posLabels; negLabels];

HOGDesc = [];

%Configurations for the HOG features
numBins = 9;
signed = 0;
cellSize = [8 8];
blockSize = [16 16];
windowSize = [64 64]; 
blockStride = 10;

%Loading Images and Getting HOG
for i=1:size(traininglist)
    imgName = strcat(trainingfolder(i),traininglist(i).name);
    disp('Getting Hog For image');
    disp(imgName{1});
    img = imread(imgName{1});
    img = imresize(img,windowSize);
    if ( size(img,3) == 3)
        imggray = rgb2gray(img);
    else
        imggray = img;
    end    
    imggray = im2double(imggray);
   
    hogDescForImg = getHOGWrapper(imggray,numBins,signed,cellSize,blockSize);
    if ( size(hogDescForImg,2) > 1 )
        pause;
    end
    %hogDescForImg = extractHOGFeatures(imggray);  
    HOGDesc = [HOGDesc; hogDescForImg'];    
end
Xtrain = HOGDesc; 
Ytrain = labels;
[genError meanAcc best_model heldOutAccBest_model full_model heldOutAccFull_model] = cross_validation(@svmrun, Xtrain, Ytrain, 10);

%Test Phase for SVM
% testposfolder = 'testsetpositive/';
% testposlist = dir(testposfolder);
% testposlist = testposlist(3:end,:);
% 
% testnegfolder = 'testsetnegative/';
% testneglist = dir(testnegfolder);
% testneglist = testneglist(3:end,:);
% 
% testlist = [testposlist; testneglist];
% testfolder = repmat({testposfolder}, [size(testposlist,1) 1]);
% testfolder = [testfolder ; repmat({testnegfolder}, [size(testneglist,1) 1])];
% 
% testposLabels = ones(size(testposlist,1),1);
% testnegLabels = zeros(size(testneglist,1),1);
% testlabels = [testposLabels; testnegLabels];
% 
% testHOGDesc = [];
% %Loading Images and Getting HOG
% for i=1:size(testlist)
%     imgName = strcat(testfolder(i),testlist(i).name);
%     disp('Getting Hog For image');
%     disp(imgName{1});
%     img = imread(imgName{1});
%     img = imresize(img,windowSize);
%     if ( size(img,3) == 3)
%         imggray = rgb2gray(img);
%     else
%         imggray = img;
%     end    
%     imggray = im2double(imggray);
%    
%     hogDescForImg = getHOGWrapper(imggray,numBins,signed,cellSize,blockSize);
%     %hogDescForImg = extractHOGFeatures(imggray);  
%     testHOGDesc = [testHOGDesc; hogDescForImg'];    
% end
% Xtest = testHOGDesc; 
% Ytest = testlabels;
% testPreds = predict(full_model,testHOGDesc);
% mean(testPreds==Ytest)

% Testing an image
% Testing an image
img = imread('videoimg1.png');
imggray = rgb2gray(img);
imggray = im2double(imggray);

% Bouning Boxes for Faces
for i=0.1:0.1:1.5
    imgres= imresize(imggray,i);
    [faceBbox,scores] = predictFace(imgres, [64 64], numBins, signed, cellSize, blockSize, blockStride, svmmodel);
    disp('Face Detected!!');
    ann_img = imgres;
    for j=1:size(faceBbox)
        faceimg = imgres(faceBbox(j,2):faceBbox(j,2)+faceBbox(j,4),faceBbox(j,1):faceBbox(j,1)+faceBbox(j,3));
        %imshow(faceimg);
        for k=1:0.25:2
            faceres = imresize(faceimg,k);
            %size(faceres)
            [eyeBbox,scores] = predictFace(faceres, [32 64], numBins, signed, cellSize, blockSize, blockStride, svmmouthdetector);
            %disp('Here!!!');
            for l=1:size(eyeBbox)
                eyeBbox
                faceres = insertObjectAnnotation(faceres,'rectangle',eyeBbox(l,:),scores(l,2));
                imshow(faceres);
                pause;
            end
        end
    end
    %rectangle('Position',boundingBoxes(j,:),'EdgeColor','y');
end