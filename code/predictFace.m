function [ boundingBoxes ] = predictFace( img, windowSize, numBins, signed, cellSize, blockSize, blockStride, model)
    [gradAngles, gradMags] = computeImageGradients(img,0);
    %yNumWindows = size(img,1)/windowSize(1);
    %xNumWindows = size(img,2)/windowSize(2);
    yStartCell = 1;
    yEndCell = yStartCell + windowSize(2)-1;
    boundingBoxes = [];
    while( yEndCell < size(img,1) )
        xStartCell = 1;
        xEndCell = xStartCell + windowSize(1)-1;
        while( xEndCell < size(img,2) )
            %cellvals = [yStartCell yEndCell xStartCell xEndCell]
            gradAng = gradAngles(yStartCell:yEndCell,xStartCell:xEndCell);
            gradMag = gradMags(yStartCell:yEndCell,xStartCell:xEndCell);
            %computeHog(gradAng,gradMag,numBins,signed)
            hogDesc = getHOGdescriptor(gradAng,gradMag,numBins,signed,cellSize,blockSize);
            prediction = predict(model,hogDesc');
            if ( prediction == 1)
                boundingBoxes = [boundingBoxes; [xStartCell yStartCell windowSize(2) windowSize(1)]];
            end
            xStartCell = xStartCell + blockStride;
            xEndCell = xStartCell + windowSize(2)-1;
        end
        yStartCell = yStartCell + blockStride;
        yEndCell = yStartCell + windowSize(1)-1;
    end
end

