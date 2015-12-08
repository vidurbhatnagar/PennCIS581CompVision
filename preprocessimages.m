% Image preprocessing - creating positive examples
trainingfolder = 'trainsetfacedetection/';
traininglist = dir(trainingfolder);
traininglist = traininglist(3:end,:);
faceDetector = vision.CascadeObjectDetector();
negLabels = zeros(1218,1);
posLabels = ones(2000,1);
labels = [negLabels; posLabels]; 
for i=1:size(traininglist)
    imgName = strcat(trainingfolder,traininglist(i).name)
    img = imread(imgName);
    bbox = step(faceDetector,img);  
    size(bbox)
    img = imresize(img,[64 64]);
    %imwrite(img,imgName);
end