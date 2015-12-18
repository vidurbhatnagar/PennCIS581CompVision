function [cornerX, cornerY, corres] = getCorrespondences(frame, faceBox, eyeBox, noseBox, mouthBox)
    I = rgb2gray(frame);
    
    %% Operate on the FACE
    face=imcrop(I,faceBox);
    faceCX = size(face,1)/2 + faceBox(1);
    faceCY = size(face,2)/2 + faceBox(2);
    
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
    
    %% Operate on the NOSE
    noseCX = noseBox(1,1) + (noseBox(1,3)/2) + faceBox(1);
    noseCY = noseBox(1,2) + (noseBox(1,4)/2);
    
    %% Operate on the MOUTH
    m=[1,noseCY,size(face,1),((size(face,2))-noseCY)];
    mouth=imcrop(face,m);
    
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
    corres =[faceCX;eyeCX1;eyeCX2;noseCX;mouthCX, faceCY;eyeCY1;eyeCY2;noseCY;mouthCY];
    
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
%     imshow(I);hold on;plot(corres(:,1),corres(:,2),'+','MarkerSize',10);
%     videoout=insertObjectAnnotation(I,'rectangle',allPoints,label,'TextBoxOpacity',0.3,'Fontsize',9);
%     imshow(videoout);
end