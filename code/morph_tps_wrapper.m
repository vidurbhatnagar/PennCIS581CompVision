function morphedImage = morph_tps_wrapper(I1, I2, I1ControlPts, I2ControlPts, warpFrac, dissolveFrac)
I1D = im2double(I1);
I2D = im2double(I2);

midImageControlPts = (1-warpFrac) * I1ControlPts + warpFrac * I2ControlPts;

%Morphed Image from Image 1
[a1X1,axX1,ayX1,wX1] = est_tps(midImageControlPts,I1ControlPts(:,1));
[a1Y1,axY1,ayY1,wY1] = est_tps(midImageControlPts,I1ControlPts(:,2));
morphedImage1 = morph_tps(I1D, a1X1, axX1, ayX1, wX1, a1Y1, axY1, ayY1, wY1, midImageControlPts, [size(I1D,1),size(I1D,2)]);

%Morphed Image from Image 2
[a1X2,axX2,ayX2,wX2] = est_tps(midImageControlPts,I2ControlPts(:,1));
[a1Y2,axY2,ayY2,wY2] = est_tps(midImageControlPts,I2ControlPts(:,2));
morphedImage2 = morph_tps(I2D, a1X2, axX2, ayX2, wX2, a1Y2, axY2, ayY2, wY2, midImageControlPts, [size(I1D,1),size(I1D,2)]);

%Final MorphedImage
morphedImage = morphedImage1 * (1-dissolveFrac) + morphedImage2 * dissolveFrac;
% figure(1);imagesc(morphedImage1);
% figure(2);imagesc(morphedImage2);
