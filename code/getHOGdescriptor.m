function [ hogDesc ] = getHOGdescriptor( gradAngles, gradMags, numBins, signed, cellSize, blockSize )
    % Get Histogram descriptor for an image/window
    % Parameters
    %   gradAngles - N by M matrix of gradient directions for each pixel in image
    %   gradMags - N by M matrix of gradient magnitudes for each pixel in image
    %   numBins - number of bins for the histogram
    %   signed - Consider angles from -pi to pi or convert to unsinged (0 to
    %   pi)
    %   cellSize - 1 by 2 vector of number of pixels to be considered in
    %   the cell [no_of_pixels_in_y no_of_pixels_in_x] 
    %   blockSize - 1 by 2 vector of number of pixels to be considered in
    %   the block ( for block level normalization ) [no_of_pixels_in_y no_of_pixels_in_x]
    numVertCells = size(gradMags,1)/cellSize(1);
    numHortCells = size(gradMags,2)/cellSize(2);
    numVertBlocks = size(gradMags,1)/blockSize(1);
    numHortBlocks = size(gradMags,2)/blockSize(2);
    
    hist = zeros(numVertCells,numHortCells,numBins);
    for row=1:numVertCells
        yStartCell = (row-1)*cellSize(2)+1;
        yEndCell =  yStartCell + cellSize(2)-1;
        for col=1:numHortCells
            xStartCell = (col-1)*cellSize(1)+1;
            xEndCell = xStartCell + cellSize(1)-1;
            %cellvals = [yStartCell yEndCell xStartCell xEndCell]
            gradAng = gradAngles(yStartCell:yEndCell,xStartCell:xEndCell);
            gradMag = gradMags(yStartCell:yEndCell,xStartCell:xEndCell);
            %computeHog(gradAng,gradMag,numBins,signed)
            hist(row,col,:) = computeHog(gradAng,gradMag,numBins,signed);
        end
    end      
    hogDesc = [];
    for row=1:numVertCells-1
        for col=1:numHortCells-1
            blockHists = hist(row:row+1,col:col+1,:);
            blockMag = norm(blockHists(:));
            blockNorm = blockHists(:)/blockMag;
            hogDesc = [hogDesc; blockNorm];
        end
    end    
end              

