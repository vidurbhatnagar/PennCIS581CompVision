function [ svmmodel ] = svmrun( train_data, train_labels, folds)
X = train_data;
Y = train_labels;
% SVM with kernal
% if ( folds > 1 )
%      svmmodel = fitcsvm(X, Y,'kernelFunction', 'kernel_intersection','kFold',folds);
%  else
%      svmmodel = fitcsvm(X, Y,'kernelFunction', 'kernel_intersection');
%  end
% SVM without kernal
if ( folds > 1 )
    svmmodel = fitcsvm(X, Y,'kFold',folds);
else
    svmmodel = fitcsvm(X, Y);
end

