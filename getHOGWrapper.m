function [hogDesc] = getHOGWrapper(img,numBins,signed,cellSize,blockSize)
% Window Size [128 64] - Face Detection Window
% Cell Size [8 8] - Histogram Calculation window
% Block Size [16 16] - BLock Size for Histogram Normalization
% Histogram Bin Size 9
% Signed 0 - Considering (pi to -pi) as ( 0 to pi) %% Needs to be tested
% for face detection
% Gradient Calculation - No smoothing, Gradient Filters [-1 0 1], [-1 0 1]'
[gradAngles, gradMags] = computeImageGradients(img,0);
hogDesc = getHOGdescriptor(gradAngles,gradMags,numBins,signed,cellSize,blockSize);
end