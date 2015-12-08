function [ boundingBoxes ] = predictFace( img, windowSize, numBins, signed, cellSize, blockSize, model)
    [gradAngles, gradMags] = computeImageGradients(img,0);
    yNumWindows = size(img,1)/windowSize(1);
    xNumWindows = size(img,2)/windowSize(2);
    boundingBoxes = [];
    for row=1:yNumWindows
        yStartCell = (row-1)*windowSize(2)+1;
        yEndCell =  yStartCell + windowSize(2)-1;
        for col=1:xNumWindows
            xStartCell = (col-1)*windowSize(1)+1;
            xEndCell = xStartCell + windowSize(1)-1;
            if ( yEndCell > size(img,1))
                continue;
            end
            if ( xEndCell > size(img,2))
                continue;
            end
            %cellvals = [yStartCell yEndCell xStartCell xEndCell]
            gradAng = gradAngles(yStartCell:yEndCell,xStartCell:xEndCell);
            gradMag = gradMags(yStartCell:yEndCell,xStartCell:xEndCell);
            %computeHog(gradAng,gradMag,numBins,signed)
            hogDesc = getHOGdescriptor(gradAng,gradMag,numBins,signed,cellSize,blockSize);
            prediction = predict(model,hogDesc');
            if ( prediction == 1)
                boundingBoxes = [boundingBoxes; [xStartCell yStartCell windowSize(2) windowSize(1)]];
            end
        end
    end
end

