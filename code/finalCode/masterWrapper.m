function masterWrapper(inputVideoName,outputVideoName)
    close all;
    
    %% Load the SVM Classifier
    svmFaceDetector = load('svmfacedetector.mat');
    svmFaceDetector = svmFaceDetector.svmfacedetector;
    
    %% Load the input video and run the algorithm for each frame
    video = VideoReader(inputVideoName);
    
    aviWriterTPS = VideoWriter(outputVideoName);
    open(aviWriterTPS);
    prevFaceBoxTar = [];
    iter = 0;
    while hasFrame(video)
        frameTar = im2double(readFrame(video));
        [frameBlended, faceBoxTar] = getBlendedFrame(frameTar, svmFaceDetector, prevFaceBoxTar);
        if (size(frameBlended))
            iter = iter + 1
            prevFaceBoxTar = faceBoxTar;
            imagesc(frameBlended);
            axis image; axis off; drawnow;        
            aviWriterTPS.writeVideo(getframe(gcf));  
        end
    end
    close(aviWriterTPS)
end