function [ H ] = computeHog( gradAngles, gradMags, numBins, signed )
% Computing Hog for window
% gradAngles - gradient angles in a window
% gradMags - gradient magnitudes in a window
% numBins - number of bins for the histogram
% signed - whether to consider angles between (-pi to pi as 0 to pi)
gradAngles = gradAngles(:);
gradMags = gradMags(:);

%% If not signed, then make negative angles positive
binSize = pi/numBins;
if ( signed==0 )
    gradAngles(gradAngles<0)=gradAngles(gradAngles<0) + pi;
end

%% Computing left and right bin indexes 
leftBinIdx = round(gradAngles/binSize);
rightBinIdx = leftBinIdx + 1;

leftBinCen = ((leftBinIdx - 0.5)*binSize);

%% Computing magnitude contributions to each bin based on the proportion of angles in each bin 
leftBinProp = (gradAngles - leftBinCen);
rightBinProp = (binSize - leftBinProp);
leftBinProp = leftBinProp/binSize;
rightBinProp = rightBinProp/binSize;

%% Setting bins to wrap if they go out of range
leftBinIdx(leftBinIdx==0) = numBins;
rightBinIdx(rightBinIdx==(numBins+1)) = 1;

%% Counting the angles in each bin according to their contributions
H = zeros(numBins,1);
for i=1:size(H,1)
    leftloc = find(leftBinIdx==i);
    H(i,1)=H(i,1) + sum((leftBinProp(leftloc))'*gradMags(leftloc));
    
    rightloc = find(rightBinIdx==i);
    H(i,1)=H(i,1) + sum((rightBinProp(rightloc))'*gradMags(rightloc));
end
end