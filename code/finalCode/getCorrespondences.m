function [cornerX, cornerY, corres, faceBox] = getCorrespondencesTest(frame, svmfacedetector, prevFaceBox)
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

    %% Configurations for face detection
    displacementThresh = 50;
    scoreThresh = 3;
    numBins = 9;
    signed = 0;
    cellSize = [8 8];
    blockSize = [16 16];
    windowSize = [64 64]; 
    blockStride = 10;

    %% Intialize Detectors
    eyeDetector = vision.CascadeObjectDetector('RightEye');
    mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',20);
    noseDetector = vision.CascadeObjectDetector('Nose','MergeThreshold',16);
   
    %% Finding the best FACE
    imggray = rgb2gray(frame);
    imggray = im2double(imggray);

    corres = [];
    cornerX = [];
    cornerY = [];
    %% Trying face detection for different scales
    %% Returns the first face found
    for i=0.1:0.05:0.7
        imgres= imresize(imggray,i);
        %% Detect faces at a particular scale 
        [resFaceBoxes,scores] = detectFace(imgres, windowSize, numBins, signed, cellSize, blockSize, blockStride, svmfacedetector);
        
        %% Suppress faces with scores lesser than scoreThresh 
        suppIdx = find(scores < scoreThresh );
        resFaceBoxes(suppIdx,:) = [];
        scores(suppIdx) = [];
        
        %% Face Box size at original image scale
        faceBoxes = resFaceBoxes*1/i;
    
        for j=1:size(faceBoxes,1)
            faceBox = faceBoxes(j,:);
            
            %% Operate on the FACE
            faceCX = faceBox(3)/2 + faceBox(1);
            faceCY = faceBox(4)/2 + faceBox(2);

            %% Check whether the detected face is further away than a displacement Threshold 
            %% Basically to curb detetion of other persons face is multiple faces
            displacement = 0;
            if ( size(prevFaceBox,1) )
                prevFaceCX = prevFaceBox(3)/2 + prevFaceBox(1);
                prevFaceCY = prevFaceBox(4)/2 + prevFaceBox(2);
                displacement = norm([faceCX faceCY] - [prevFaceCX prevFaceCY]);
            end
        
            if ( displacement > displacementThresh )
                continue;
            end
            
            %% Crop Face Image
            face=imcrop(frame,faceBox);
            
            %% Detect NOSE
            noseBox=step(noseDetector,face);
            if ( ~size(noseBox,1) )
                continue;
            end
            noseCenX = noseBox(:,3)/2 + noseBox(:,1);
            noseCenY = noseBox(:,4)/2 + noseBox(:,2);
            
            %% Consider nose that is nearest to face center
            proximity = sqrt(sum(abs([noseCenX noseCenY]-repmat([faceCX faceCY],size(noseCenX,1),1))));
            [~,nosePos] = min(proximity,[],1);
            noseBox = noseBox(nosePos,:);    
           
            %% Operate on the NOSE
            noseCX = noseBox(1,1) + (noseBox(1,3)/2) + faceBox(1);
            noseCY = noseBox(1,2) + (noseBox(1,4)/2);

            eyeZone=imcrop(face,[1,1,size(face,2),noseCY]);
            
            %% Detect Eyes only in the region above the nose
            eyeBox=step(eyeDetector,eyeZone);
            if ( ~size(eyeBox,1) )
                continue;
            end

            %% Operate on the EYES   
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
            
            %% Detect MOUTH in region below the nose 
            m=[1,noseCY,size(face,1),((size(face,2))-noseCY)];
            mouth=imcrop(face,m);

            %% Operate on the MOUTH
            mouthBox=step(mouthDetector,mouth);
            if ( ~size(mouthBox,1) )
                continue;
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

            %% Get all CORRESPONDENCES ( Centers of face landmarks )
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
            %imshow(frame);hold on;plot(corres(:,1),corres(:,2),'+','MarkerSize',10);
            %videoout=insertObjectAnnotation(frame,'rectangle',allPoints,'P','TextBoxOpacity',0.3,'Fontsize',9);
            %imshow(videoout);
            %pause;
            if ( size(corres,1) )
                break;
            end
        end
        if ( size(corres,1) )
            break;
        else
            faceBox = [];
        end
    end
end