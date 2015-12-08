function [genError meanAcc best_model heldOutAccBest_model full_model heldOutAccFull_model] = cross_validation(method_handle, Xtrain, Ytrain, folds)
    tic
    cvPart = cvpartition(size(Xtrain,1),'HoldOut');
    heldOut = test(cvPart);   
    heldIn = ~heldOut;
    heldInTrainFeat = Xtrain(heldIn,:);
    heldInTrainLabel = Ytrain(heldIn,:);
    heldOutTrainFeat = Xtrain(heldOut,:);
    heldOutTrainLabel = Ytrain(heldOut,:);
    
    %CV Find the best model
    models = method_handle(heldInTrainFeat,heldInTrainLabel,folds);
    trainedModels = models.Trained;
    genError = kfoldLoss(models,'Mode','Individual');
    
    %Mean Accuracy for all CV models
    meanError = mean(genError);
    meanAcc = 1 - meanError;
    
    % Best Model from CV held Out Accuracy
    [min_err, loc] = min(genError);
    best_model = trainedModels{loc};
    heldOutPredBestMdl = predict(best_model,heldOutTrainFeat);
    heldOutPredBestMdl(heldOutPredBestMdl>=0.5)=1;
    heldOutPredBestMdl(heldOutPredBestMdl<0.5)=0;
    heldOutAccBest_model = mean(heldOutPredBestMdl == heldOutTrainLabel);
    
    % Best Model trained on all held in data
    folds = 1;
    full_model = method_handle(heldInTrainFeat,heldInTrainLabel,folds);
    heldOutPredFullMdl = predict(full_model,heldOutTrainFeat);
    heldOutPredFullMdl(heldOutPredFullMdl>=0.5)=1;
    heldOutPredFullMdl(heldOutPredFullMdl<0.5)=0;
    heldOutAccFull_model = mean(heldOutPredFullMdl == heldOutTrainLabel);
    toc
end