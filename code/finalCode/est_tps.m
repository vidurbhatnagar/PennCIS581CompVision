function[a1,aX,aY,w] = est_tps(controlPts, targetValues)
%|K  P||W| = |V|
%|PT 0||ax|  |0|
%      |ay|
%      |a1| 
rows = length(controlPts);

matDiff = @(cPts) repmat(cPts, 1, rows) - transpose(repmat(cPts, 1, rows));
rMatrixSq = matDiff(controlPts(:,1)).^2 + matDiff(controlPts(:,2)).^2;
kMatrix = rMatrixSq.*log(rMatrixSq) ;
kMatrix(isnan(kMatrix)) = 0;
pMatrix = [controlPts, ones(rows,1)];
zeroMatrix  = zeros(3,3);
concatMatrix = [kMatrix, pMatrix; pMatrix', zeroMatrix];

lambda = eps;
invConcatMatrix = inv(concatMatrix + lambda*eye(rows+3, rows+3));

vVector = [targetValues; [0;0;0]];
resultVector =  invConcatMatrix * vVector;

w = resultVector(1:rows);
aX = resultVector(rows+1);
aY = resultVector(rows+2);
a1 = resultVector(rows+3);