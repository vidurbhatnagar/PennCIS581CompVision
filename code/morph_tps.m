function [morphedImageRes] = morph_tps(I, a1X, axX, ayX, wX, a1Y, axY, ayY, wY, controlPts, ISize)
rows = size(I,1);
cols = size(I,2);
totalPixels = rows*cols;
totalControlPts = length(controlPts);

pixelsLinear = [1:totalPixels];
[pixelsY,pixelsX] = ind2sub([rows,cols],pixelsLinear);
rowIt = reshape(pixelsY,rows,cols);
colIt = reshape(pixelsX,rows,cols);
bilinearR = griddedInterpolant(rowIt,colIt,I(:,:,1));
bilinearG = griddedInterpolant(rowIt,colIt,I(:,:,2));
bilinearB = griddedInterpolant(rowIt,colIt,I(:,:,3));

pixelsXY = [pixelsX',pixelsY'];
pixelsXY1 = [pixelsXY, repmat(1,totalPixels,1)];

% Building the matrices for TSP
matDiff = @(pXY, cPts) bsxfun(@minus, repmat(pXY, 1, totalControlPts), repmat(cPts',totalPixels,1));
rMatrixSq = matDiff(pixelsXY(:,1), controlPts(:,1)).^2 + matDiff(pixelsXY(:,2), controlPts(:,2)).^2;

kMatrix = rMatrixSq.*log(rMatrixSq);
kMatrix(isnan(kMatrix)) = 0;
kMatrixXY1 = [kMatrix,pixelsXY1];

wMatrixX = [wX;axX;ayX;a1X];
wMatrixY = [wY;axY;ayY;a1Y];

%Finding the equivalent Pixels in Original Image for inverse warping
IX = kMatrixXY1 * wMatrixX;
IY = kMatrixXY1 * wMatrixY;

IX(IX > cols) = cols;
IX(IX < 1) = 1;
IY(IY > rows) = rows;
IY(IY < 1) = 1;

midImage = zeros(totalPixels,3);
intensityR = bilinearR(IY(:),IX(:));
intensityG = bilinearG(IY(:),IX(:));
intensityB = bilinearB(IY(:),IX(:));

midImage(:,1) = bilinearR(IY(:),IX(:));
midImage(:,2) = bilinearG(IY(:),IX(:));
midImage(:,3) = bilinearB(IY(:),IX(:));
morphedImage  = reshape(midImage, rows, cols, 3);
morphedImageRes = imresize(morphedImage,ISize);
