% Train logistic classifier.
function logistic = learchtrainlogistic(y,x)

w = glmfit(x,y,'binomial','link','logit');
logistic = struct('w',w);
