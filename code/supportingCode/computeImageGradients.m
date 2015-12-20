function [ gradAngles, gradMags ] = computeImageGradients( img, gaussSigma )
% COMPUTEIMAGEGRADIENTS - Computing image gradients
% Using [1 0 -1] and [1 0 -1]'
% Mirror padding at the edges 
xFilt = [1 0 -1];
yFilt = [1 0 -1]';
if ( gaussSigma ~= 0 )
    img = imgaussfilt(img,gaussSigma);
end
xPadImgGrad = padarray(img,[0 1],'symmetric','both');
xGrad = conv2(xPadImgGrad,xFilt,'valid');
yPadImgGrad = padarray(img,[1 0],'symmetric','both');
yGrad = conv2(yPadImgGrad,yFilt,'valid');
gradMags = sqrt(xGrad.*xGrad + yGrad.*yGrad);
gradAngles = atan2(yGrad,xGrad);
end