function [frameBlended, faceBoxTar] = getBlendedFrame(frameTar, svmFaceDetector, prevFaceBoxTar)
    close all;
    %% Load srcData - frameSrc,cornerXSrc,cornerYSrc,corresSrc
    load('srcPoints.mat')
    
    %% Load tarData - call to getCorrespondences    
    [cornerXTar, cornerYTar, corresTar, faceBoxTar] = getCorrespondences(frameTar, svmFaceDetector, prevFaceBoxTar);    
    if (~size(corresTar))
        frameBlended = [];
        faceBoxTar = prevFaceBoxTar;
        return;
    end
    
    %% Calculate convex hull of the source image 
    [rows, cols, ~] = size(frameSrc);
    totalPixels = rows*cols;
    pixelsLinear = [1:totalPixels];
    [rowIter,colIter] = ind2sub([rows,cols],pixelsLinear);
    
    convHull = convhull(cornerXSrc,cornerYSrc);
    srcIn = inpolygon(colIter,rowIter,cornerXSrc(convHull),cornerYSrc(convHull));
    srcIn = find(srcIn==1);
    
    faceSrc = zeros(size(frameSrc));
    faceSrc(faceSrc==0) = -1;
    for iter = 1:length(srcIn)
        faceSrc(rowIter(srcIn(iter)),colIter(srcIn(iter)),:) = im2double(frameSrc(rowIter(srcIn(iter)),colIter(srcIn(iter)),:));
    end
    
    %% Calculate convex hull of the target image 
    [rows, cols, ~] = size(frameTar);
    totalPixels = rows*cols;
    pixelsLinear = [1:totalPixels];
    [rowIter,colIter] = ind2sub([rows,cols],pixelsLinear);
    
    convHull = convhull(cornerXTar,cornerYTar);
    tarIn = inpolygon(colIter,rowIter,cornerXTar(convHull),cornerYTar(convHull));
    tarIn = find(tarIn==1);
    
    faceTar = zeros(size(frameTar));
    faceTar(faceTar==0) = -1;
    for iter = 1:length(tarIn)
        faceTar(rowIter(tarIn(iter)),colIter(tarIn(iter)),:) = im2double(frameTar(rowIter(tarIn(iter)),colIter(tarIn(iter)),:));
    end
    
    %% Generate Morphed Image
    morphedImage1 = im2double(morph_tps_wrapper(faceSrc, faceTar, corresSrc, corresTar, 1, 0));
    morphedImage2 = im2double(morph_tps_wrapper(frameSrc, frameTar, corresSrc, corresTar, 1, 0));
    
    %% Generating Mask
    mask = morphedImage1;
    mask(mask>=0) = 1;
    mask(mask<0) = 0;
    
    %% Gradient Domain Blending
    frameBlended =  gradientDomainBlend(morphedImage2,frameTar,mask);
      
    %% Poisson Blending
%     positiveIndices = find(morphedImage1>=0);
%     commonIndices = intersect(tarIn,positiveIndices);
%     [rowIter,colIter] = ind2sub([rows,cols],commonIndices);
%     
%     frameMorphed = frameTar;
%     for iter = 1:length(commonIndices)
%         pixelVal = morphedImage2(rowIter(iter),colIter(iter),:);
%         frameMorphed(rowIter(iter),colIter(iter),:) = pixelVal;
%     end
% 
%     [Lh Lv] = imgrad(frameTar);
%     [Gh Gv] = imgrad(morphedImage2);
%     Fh = Lh;
%     Fv = Lv;
% 
%     for iter = 1:length(commonIndices)
%             Fh(rowIter(iter),colIter(iter),:) = Gh(rowIter(iter),colIter(iter),:);
%             Fv(rowIter(iter),colIter(iter),:) = Gv(rowIter(iter),colIter(iter),:);
%     end
%     
%     frameBlended = PoissonGaussSeidel(frameMorphed, Fh, Fv, mask);

    %% Laplacian Blending
%     frameBlended = LaplacianBlend(frameTar, morphedImage2, mask);
    
    %% Generate Visualizations
%     figure;imshow(frameBlended);
%     imshow(morphedImage1);
%     figure;
%     imshow(morphedImage1);
%     imshow(frameMorphed);
%     figure;
%     imshow(frameTar);
%     hold on;
%     plot(corresTar(:,1),corresTar(:,2),'+','MarkerSize',10);


end