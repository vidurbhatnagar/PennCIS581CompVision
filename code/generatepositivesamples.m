% Generating positive samples from face datasets
% Detect faces from face images and resizing to [64 64]
datasetfolder = 'proj4/data/caltech_faces/Caltech_CropFaces/'
trainingfolder = 'trainsetpositive/';
datasetlist = dir(datasetfolder);
datasetlist = datasetlist(3:end,:);

windowSize = [64 64];
%faceDetector = vision.CascadeObjectDetector();

for i=1:size(datasetlist)
    fileName = datasetlist(i).name;
    [pathstr,name,ext] = fileparts(fileName);
    if ( strcmp(ext,'.pts') )
        continue;
    end
    imgName = strcat(datasetfolder,fileName);
    disp('Preprocessing image');
    disp(imgName);
    img = imread(imgName);
    img = im2double(img);
    imgsave = imresize(img,[64 64]);
    %imshow(img);
    %pause;
    
    %bbox = step(faceDetector, img);
    %if ( size(bbox,1) > 0 )
     %   for i=1:size(bbox,1)
      %      cropImg = img(bbox(i,2):bbox(i,2)+bbox(i,4),bbox(i,1):bbox(i,1)+bbox(i,3),:);
       %     imgsave = imresize(cropImg,windowSize);
       % end
    %else
     %     imgsave = imresize(img,windowSize);
    %end
    %imshow(imgsave);
    %pause;
    imgName = strcat(trainingfolder,fileName);
    imwrite(imgsave,imgName);
end