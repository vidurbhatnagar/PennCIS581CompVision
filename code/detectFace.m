function [ boundingBoxes, scores ] = detectFace( img, windowSize, numBins, signed, cellSize, blockSize, blockStride, model)
    % Predicts faces in an image ( Runs a window of windowSize )
    % Gets the hog descriptors for sliding windows and passes it to the
    % face detetcor svm
    % SVM predicts whether the passed hog features correspond to a face or
    % not
    % Parameters
    %   img - image in which face have to be detected
    %   numBins - number of bins for the histogram
    %   signed - Consider angles from -pi to pi or convert to unsinged (0 to
    %   pi)
    %   cellSize - 1 by 2 vector of number of pixels to be considered in
    %   the cell [no_of_pixels_in_y no_of_pixels_in_x] 
    %   blockSize - 1 by 2 vector of number of pixels to be considered in
    %   the block ( for block level normalization ) [no_of_pixels_in_y no_of_pixels_in_x]
    %   model - pre trained svm model that predicts whether a window is face or not
    % Returns
    %   boundingBoxes - c by 4 matrix of bounding box for a face in an image
    %   where a bounding box is [cornerX,cornerY,width,height]
    %   score - Svm confidence score in each prediction
    [gradAngles, gradMags] = computeImageGradients(img,0);
    yStartCell = 1;
    yEndCell = yStartCell + windowSize(1)-1;
    bboxDesc = [];
    while( yEndCell < size(img,1) )
        xStartCell = 1;
        xEndCell = xStartCell + windowSize(2)-1;
        while( xEndCell < size(img,2) )
            %cellvals = [yStartCell yEndCell xStartCell xEndCell]
            gradAng = gradAngles(yStartCell:yEndCell,xStartCell:xEndCell);
            gradMag = gradMags(yStartCell:yEndCell,xStartCell:xEndCell);
            %computeHog(gradAng,gradMag,numBins,signed)
            hogDesc = getHOGdescriptor(gradAng,gradMag,numBins,signed,cellSize,blockSize);
            bboxDesc = [bboxDesc; xStartCell,yStartCell,hogDesc'];
            xStartCell = xStartCell + blockStride;
            xEndCell = xStartCell + windowSize(2)-1;
        end
        yStartCell = yStartCell + blockStride;
        yEndCell = yStartCell + windowSize(1)-1;
    end
    boundingBoxes = [];
    scores = [];
    if ( size(bboxDesc,1) )
        [preds,predscores] = predict(model,bboxDesc(:,3:end));
        faceIdx = find(preds == 1);
        if ( size(faceIdx) )
            boundingBoxes = [bboxDesc(faceIdx,1:2) repmat(windowSize(2),size(faceIdx)) repmat(windowSize(1),size(faceIdx))];
            scores = predscores(faceIdx,2); 
        end
    end
end