function [cornerX, cornerY, corres, faceBox] = getCorrespondences(frame, svmfacedetector, prevFaceBox)
% For Detecting a face in the frame and getting face landmarks/correspondences
% First detect a candidate faces in the image - Then use Viola Jones
% Cascade detector to get face features
% Use these to figure out the best face candidate
% Find Face Landmarks ( based on face features ) and return them as
% correspondences for downstream warp
% PARAMS
% frame - N by M by 3 matrix (image) which corresponds to each frame of the
% video
% svmfacedetector
% prevFaceBox - face bounding box of the previous frame - Used to keep a
% basic check the face detected is not too faraway from the face detected
% in the previous frame
% RETURNS
% cornerX - X coords of the correspondences 
% cornerY - Y coords of the correspondences
% correspondes - M by 2 matrix containing (X,Y) coordinates of the
% corresponding landmark points

% Configurations for face detection
displacementThresh = 50;
scoreThresh = 3;
numBins = 9;
signed = 0;
cellSize = [8 8];
blockSize = [16 16];
windowSize = [64 64]; 
blockStride = 10;

%Intialize Detectors
eyeDetector = vision.CascadeObjectDetector('RightEye');
mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',20);
noseDetector = vision.CascadeObjectDetector('Nose','MergeThreshold',16);
faceDetector = vision.CascadeObjectDetector();

imggray = rgb2gray(frame);
imggray = im2double(imggray);

corres = [];
cornerX = [];
cornerY = [];
for i=0.1:0.05:0.7
    disp('Scale Tried:');
    disp(i);
    imgres= imresize(imggray,i);
    [resFaceBox,scores] = detectFace(imgres, windowSize, numBins, signed, cellSize, blockSize, blockStride, svmfacedetector);
    suppIdx = find(scores < scoreThresh );
    resFaceBox(suppIdx,:) = [];
    scores(suppIdx) = [];
    faceBox = resFaceBox*1/i;
%     decface = insertObjectAnnotation(imgres,'rectangle',faceBbox,scores);
%     imshow(decface);
%     pause;
%     fullFace = insertObjectAnnotation(imggray,'rectangle',scaledBbox,scores);
%     imshow(fullFace);
%     pause;
    for j=1:size(faceBox,1)
        displacement = 0;
        if ( size(prevFaceBox,1) )
            displacement = norm(faceBox(j,1:2) - prevFaceBox);
        end
        
        if ( displacement > displacementThresh )
            continue;
        end
        
        % Face Refinement .... need to relook
        %oldFaceBox = faceBox;
        face=imcrop(frame,faceBox);
        %faceBox = step(faceDetector,face);
        %face=imcrop(face,faceBox);
        %faceBox(1,:) = faceBox(1,1:2) + oldFaceBox(1,1:2);
        %imshow(face);
        %pause;
        
        %To detect Nose
%        faceCenter = [scaledBbox(j,3) scaledBbox(j,4)]./2;          
%          if ( size(noseBbox) )
%             proximity = norm(noseBbox(:,1:2)-repmat(faceCenter,size(noseBbox,1),1));
%             [~,minPos] = min(proximity,[],1);
%             noseBbox = noseBbox(minPos,:);
%          end
%          displacement
%          prevFaceBbox
%          scaledBbox(j,:)                  
            %% Operate on the FACE
        faceCX = size(face,1)/2 + faceBox(1);
        faceCY = size(face,2)/2 + faceBox(2);
    
        %% Detect nose
        noseBox=step(noseDetector,face);
        if ( ~size(noseBox,1) )
            continue;
        end
        proximity = sqrtm(sum(noseBox(:,1:2)-repmat([faceCX faceCY],size(noseBox,1),1)));
        [~,nosePos] = min(proximity,[],1);
        noseBox = noseBox(nosePos,:);    
        
        %% Operate on the NOSE
        noseCX = noseBox(1,1) + (noseBox(1,3)/2) + faceBox(1);
        noseCY = noseBox(1,2) + (noseBox(1,4)/2);
    
        eyeZone=imcrop(face,[1,1,size(face,2),noseCY]);
    
        %Detect Eyes
        eyeBox=step(eyeDetector,eyeZone);
        if ( ~size(eyeBox,1) )
            continue;
        end
    
        %% Operate on the eyes   
        n=size(eyeBox,1);
        e=[];
        d=0;
        for it=1:n
            for j=1:n
                if (j > it)
                    if ((abs(eyeBox(j,2)-eyeBox(it,2))<68)&& (abs(eyeBox(j,1)-eyeBox(it,1))>40))
                        e(1,:)=eyeBox(it,:);
                        e(2,:)=eyeBox(j,:);
                        d=1;break;
                    end
                end
            end
            if(d == 1)
                break;
            end
        end
        if ( ~size(e))
            continue;
        end
        eyeBox(1,:) = e(1,:);
        eyeBox(2,:) = e(2,:);
    
        c = eyeBox(1,3)/2;
        d = eyeBox(1,4)/2;
        e = eyeBox(2,3)/2;
        f = eyeBox(2,4)/2;
    
        eyeCX1 = eyeBox(1,1) + c + faceBox(1);
        eyeCY1 = eyeBox(1,2)+ d + faceBox(2);
        eyeCX2 = eyeBox(2,1)+ e + faceBox(1);
        eyeCY2 = eyeBox(2,2)+ f + faceBox(2);
    
        %% Operate on the MOUTH
        m=[1,noseCY,size(face,1),((size(face,2))-noseCY)];
        mouth=imcrop(face,m);
    
        %% Detect mouth
        mouthBox=step(mouthDetector,mouth);
        if ( ~size(mouthBox,1) )
            return;
        end
    
        for it=1:size(mouthBox,1)
            if(mouthBox(it,2)>20)
                mouthBox(1,:)=mouthBox(it,:);
                break;
            end
        end
        mouthBox(1,2)=mouthBox(1,2)+noseCY;
        noseCY=noseCY+faceBox(2);
    
        mouthCX = mouthBox(1,1) + (mouthBox(1,3)/2) + faceBox(1);
        mouthCY = mouthBox(1,2) + (mouthBox(1,4)/2) + faceBox(2);
    
        %% Get all CORRESPONDENCES
        corres =[[eyeCX1;eyeCX2;noseCX;mouthCX], [eyeCY1;eyeCY2;noseCY;mouthCY]];
    
        %% Get all CORNERS to build convex hull
        eyeBox(1,1:2) = eyeBox(1,1:2) + faceBox(1,1:2);
        eyeBox(2,1:2) = eyeBox(2,1:2) + faceBox(1,1:2);
        noseBox(1,1:2) = noseBox(1,1:2) + faceBox(1,1:2);
        mouthBox(1,1:2) = mouthBox(1,1:2) + faceBox(1,1:2);
        allPoints = [eyeBox(1,:);eyeBox(2,:);noseBox(1,:);mouthBox(1,:)];
        
        cornerX = [allPoints(:,1);...
                    allPoints(:,1);...
                    allPoints(:,1)+allPoints(:,3);...
                    allPoints(:,1)+allPoints(:,3)];
        cornerY = [allPoints(:,2);...
                    allPoints(:,2)+allPoints(:,4);...
                    allPoints(:,2);...
                    allPoints(:,2)+allPoints(:,4)];
    
        %% Show all visualizations
        imshow(frame);hold on;plot(corres(:,1),corres(:,2),'+','MarkerSize',10);
        %videoout=insertObjectAnnotation(frame,'rectangle',allPoints,'P','TextBoxOpacity',0.3,'Fontsize',9);
        %imshow(videoout);
        pause;
    end
    if ( size(corres,1) )
        break;
    end
end
% ann_img = insertObjectAnnotation(image,'rectangle',faceBboxes,'Detection');
% imshow(ann_img);
% pause;