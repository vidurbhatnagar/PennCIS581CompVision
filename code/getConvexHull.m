function convexHull = getConvexHull(frameTar)
    close all;
    %% Load srcData - frameSrc,cornerXSrc,cornerYSrc,corresSrc
    load('warpPoints.mat')
    
    %% Load tarData - call to getCorrespondences    
%     [cornerXTar, cornerYTar, corresTar] = getCorrespondences(frameTar);    
    
    %% Generate Morphed Image
%     morphedImage1 = morph_tps_wrapper(frameSrc, frameTar, corresSrc, corresTar, 1, 0);
    
    %% Calculate convex hull of the source image 
    [rows, cols, ~] = size(frameSrc);
    totalPixels = rows*cols;
    pixelsLinear = [1:totalPixels];
    [rowIter,colIter] = ind2sub([rows,cols],pixelsLinear);
    
    convHull = convhull(cornerXSrc,cornerYSrc);
    [srcIn,srcOn] = inpolygon(colIter,rowIter,cornerXSrc(convHull),cornerYSrc(convHull));
    srcIn = find(srcIn==1);
    srcOn = find(srcOn==1);
    
    faceSrc = zeros(size(frameSrc));
    faceSrc(faceSrc==0) = -1;
    for iter = 1:length(srcIn)
        faceSrc(rowIter(srcIn(iter)),colIter(srcIn(iter)),:) = im2double(frameSrc(rowIter(srcIn(iter)),colIter(srcIn(iter)),:));
    end
    
%     imshow(frameSrc);hold on; 
%     plot(colIter(in),rowIter(in),'+','MarkerSize',10);
    
    %% Calculate convex hull of the target image 
    [rows, cols, ~] = size(frameTar);
    totalPixels = rows*cols;
    pixelsLinear = [1:totalPixels];
    [rowIter,colIter] = ind2sub([rows,cols],pixelsLinear);
    
    convHull = convhull(cornerXTar,cornerYTar);
    [tarIn,~] = inpolygon(colIter,rowIter,cornerXTar(convHull),cornerYTar(convHull));
    tarIn = find(tarIn==1);
    
    faceTar = zeros(size(frameTar));
    faceTar(faceTar==0) = -1;
    for iter = 1:length(tarIn)
        faceTar(rowIter(tarIn(iter)),colIter(tarIn(iter)),:) = im2double(frameTar(rowIter(tarIn(iter)),colIter(tarIn(iter)),:));
    end
    
    %% Generate Morphed Image
    morphedImage1 = im2double(morph_tps_wrapper(faceSrc, frameTar, corresSrc, corresTar, 1, 0));
    morphedImage2 = im2double(morph_tps_wrapper(frameSrc, faceTar, corresSrc, corresTar, 1, 0));
    
    %% Overlay Morphed Image onto the target frame
    positiveIndices = find(morphedImage1>=0);
    commonIndices = intersect(tarIn,positiveIndices);
%     commonIndices = in;
    [rowIter,colIter] = ind2sub([rows,cols],commonIndices);
    
    frameOverlay = frameTar;
    for iter = 1:length(commonIndices)
        pixelVal = morphedImage2(rowIter(iter),colIter(iter),:);
        frameOverlay(rowIter(iter),colIter(iter),:) = pixelVal;
    end
    
    %% Poisson Blending
    [Lh Lv] = imgrad(frameTar);
    [Gh Gv] = imgrad(frameOverlay);
    Fh = Lh;
    Fv = Lv;
    %frameFinal %X(LY:LY+h,LX:LX+w,:) = girl(GY:GY+h,GX:GX+w,:);
    for iter = 1:length(commonIndices)
            Fh(rowIter(iter),colIter(iter),:) = Gh(rowIter(iter),colIter(iter),:);
            Fv(rowIter(iter),colIter(iter),:) = Gv(rowIter(iter),colIter(iter),:);
    end
    
    mask = morphedImage1;
    mask(mask>=0) = 1;
    mask(mask<0) = 0;
    
%     mask = zeros(size(morphedImage1));
%     for iter = 1:length(commonIndices)
%         mask(rowIter(iter),colIter(iter),:) = 1;
%     end
    frameFinal = PoissonJacobi(frameOverlay, Fh, Fv, mask);
%     frameFinal = PoissonGaussSeidel(frameOverlay, Fh, Fv, mask, 1024, 0.01);

    %% Generate Visualizations
    
%     imshow(morphedImage1);
    figure;
    imshow(morphedImage1);
    imshow(frameFinal);
%     figure;
%     imshow(frameTar);
%     hold on;
%     plot(colIter,rowIter,'+','MarkerSize',10);

end