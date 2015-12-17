function [ H ] = computeHog( gradAngles, gradMags, numBins, signed )
% Computing Hog for window
% gradAngles - gradient angles in a window
% gradMags - gradient magnitudes in a window
% numBins - number of bins for the histogram
% signed - whether to consider angles between (-pi to pi as 0 to pi)
gradAngles = gradAngles(:);
gradMags = gradMags(:);

binSize = pi/numBins;
if ( signed==0 )
    gradAngles(gradAngles<0)=gradAngles(gradAngles<0) + pi;
end

leftBinIdx = round(gradAngles/binSize);
rightBinIdx = leftBinIdx + 1;

leftBinCen = ((leftBinIdx - 0.5)*binSize);
%rightBinCen = ((rightBinIdx - 0.5)*binSize)

leftBinProp = (gradAngles - leftBinCen);
rightBinProp = (binSize - leftBinProp);
leftBinProp = leftBinProp/binSize;
rightBinProp = rightBinProp/binSize;

leftBinIdx(leftBinIdx==0) = numBins;
rightBinIdx(rightBinIdx==(numBins+1)) = 1;

H = zeros(numBins,1);
for i=1:size(H,1)
    leftloc = find(leftBinIdx==i);
    H(i,1)=H(i,1) + sum((leftBinProp(leftloc))'*gradMags(leftloc));
    
    rightloc = find(rightBinIdx==i);
    H(i,1)=H(i,1) + sum((rightBinProp(rightloc))'*gradMags(rightloc));
end
end