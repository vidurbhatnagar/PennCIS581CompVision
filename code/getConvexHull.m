% function convexHull = getConvexHull(eyesBox, noseBox, mouthBox)
    [rows, cols, ~] = size(frameSrc);
    totalPixels = rows*cols;
    pixelsLinear = [1:totalPixels];
    [rowIter,colIter] = ind2sub([rows,cols],pixelsLinear);
    
    convHull = convhull(cornerXSrc,cornerYSrc);
    [in,on] = inpolygon(colIter,rowIter,cornerXSrc(convHull),cornerYSrc(convHull));
    faceSrc = zeros(size(frameSrc));
    in = find(in==1);
    for iter = 1:length(in)
        faceSrc(rowIter(in(iter)),colIter(in(iter)),:) = im2double(frameSrc(rowIter(in(iter)),colIter(in(iter)),:));
    end
%     imshow(frameSrc);hold on; 
%     plot(colIter(in),rowIter(in),'+','MarkerSize',10);
    
    convHull = convhull(cornerXTar,cornerYTar);
    [in,on] = inpolygon(colIter,rowIter,cornerXTar(convHull),cornerYTar(convHull));
    in = find(in==1);
    faceTar = zeros(size(frameTar));
    for iter = 1:length(in)
        faceTar(rowIter(in(iter)),colIter(in(iter)),:) = im2double(frameTar(rowIter(in(iter)),colIter(in(iter)),:));
    end
    
    morphedImage1 = morph_tps_wrapper(frameSrc, frameTar, corresSrc, corresTar, 1, 0);
    
    frameFinal = im2double(frameTar);
    for iter = 1:length(in)
        frameFinal(rowIter(in(iter)),colIter(in(iter)),:) = im2double(morphedImage1(rowIter(in(iter)),colIter(in(iter)),:));
    end
    
%     morphedFaceIndices = (morphedImage1~=0);
%     frameFinal = im2double(frameTar) .* im2double(morphedImage1==0);
%     frameFinal(morphedImage1~=0) = morphedImage1(morphedImage1~=0);
    imshow(frameFinal);
% end