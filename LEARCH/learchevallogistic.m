% Evaluate logistic classifier.
function fit = learchevallogistic(logistic,x)

% Add column of 1s.
x = horzcat(ones(size(x,1),1),x);

% Evaluate logistic.
fit = 1./(1+exp(-sum(bsxfun(@times,x,logistic.w'),2)));
