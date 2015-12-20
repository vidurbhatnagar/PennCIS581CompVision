% Generating negative samples from face datasets
% Detect backgorund fro, various images and take them 
datasetfolder = 'testsetpositive/';
trainingfolder = 'testsetnegative/';
datasetlist = dir(datasetfolder);
datasetlist = datasetlist(3:end,:);

windowSize = [64 64];

cnt = 0;
for i=1:size(datasetlist)
    fileName = datasetlist(i).name;
    [pathstr,name,ext] = fileparts(fileName);
    imgName = strcat(datasetfolder,fileName);
    disp('Preprocessing image');
    disp(imgName);
    img = imread(imgName);
    img = im2double(img);
    %imshow(img);
    %pause;
    
    winSizes = rand(4,2);
    winSizes(:,1) = windowSize(1)*winSizes(:,1)/2 + windowSize(1)/4;
    winSizes(:,2) = windowSize(2)*winSizes(:,2)/2 + windowSize(2)/4;
    imgDims = [[1 1]; [1 size(img,2)]; [size(img,1) 1]; [size(img,1) size(img,2)]];
    
    imgsave = img(round(imgDims(1,1)):round(imgDims(1,1)+winSizes(1,1)),round(imgDims(1,2)):round(imgDims(1,2)+winSizes(1,2)),:);
    imgsave = imresize(imgsave,windowSize);
    imgName_pre = strcat(trainingfolder,name);
    imgName_cnt = strcat(imgName_pre,num2str(1));
    imgName = strcat(imgName_cnt,ext);
    %imshow(imgsave);
    %pause;
    imwrite(imgsave,imgName);

    imgsave = img(round(imgDims(2,1)):round(imgDims(2,1)+winSizes(2,1)),round(imgDims(2,2)-winSizes(2,2)):round(imgDims(2,2)),:);
    imgsave = imresize(imgsave,windowSize);
    imgName_pre = strcat(trainingfolder,name);
    imgName_cnt = strcat(imgName_pre,num2str(2));
    imgName = strcat(imgName_cnt,ext);
    %imshow(imgsave);
    %pause;
    imwrite(imgsave,imgName);

    imgsave = img(round(imgDims(3,1)-winSizes(3,1)):round(imgDims(3,1)),round(imgDims(3,2)):round(imgDims(3,2)+winSizes(3,2)),:);
    imgsave = imresize(imgsave,windowSize);
    imgName_pre = strcat(trainingfolder,name);
    imgName_cnt = strcat(imgName_pre,num2str(3));
    imgName = strcat(imgName_cnt,ext);
    %imshow(imgsave);
    %pause;
    imwrite(imgsave,imgName);

    imgsave = img(round(imgDims(4,1)-winSizes(4,1)):round(imgDims(4,1)),round(imgDims(4,2)-winSizes(4,2)):round(imgDims(4,2)),:);
    imgsave = imresize(imgsave,windowSize);
    imgName_pre = strcat(trainingfolder,name);
    imgName_cnt = strcat(imgName_pre,num2str(4));
    imgName = strcat(imgName_cnt,ext);
    %imshow(imgsave);
    %pause;
    imwrite(imgsave,imgName);
end