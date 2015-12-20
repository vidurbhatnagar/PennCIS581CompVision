% Generating negative samples from face datasets
% Break images into blocks and then take them as negative samples
datasetfolder = 'INRIA/';
trainingfolder = 'testsetnegative/';
datasetlist = dir(datasetfolder);
datasetlist = datasetlist(3:end,:);

windowSize = [64 64];

cnt = 0;
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
    
    yNumWindows = size(img,1)/windowSize(1);
    xNumWindows = size(img,2)/windowSize(2);    

    for row=1:yNumWindows
        yStartCell = (row-1)*windowSize(2)+1;
        yEndCell =  yStartCell + windowSize(2)-1;
        if ( yEndCell > size(img,1))
            yEndCell = size(img,1);
        end
        for col=1:xNumWindows
            cnt = cnt + 1;
            xStartCell = (col-1)*windowSize(1)+1;
            xEndCell = xStartCell + windowSize(1)-1;
            if ( xEndCell > size(img,2))
                xEndCell = size(img,2);
            end
            cropImg = img(yStartCell:yEndCell,xStartCell:xEndCell,:);
            imgsave = imresize(cropImg,windowSize);
            imgName_pre = strcat(trainingfolder,name);
            imgName_cnt = strcat(imgName_pre,num2str(cnt));
            imgName = strcat(imgName_cnt,ext);
            imwrite(imgsave,imgName);
        end
    end 
end