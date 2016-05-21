% Compute column-wise softmax of a matrix.
function v = maxentsoftmax(q)

% Find maximum elements.
maxx = max(q,[],2);

% Compute safe softmax.
v = maxx + log(sum(exp(q - repmat(maxx,1,size(q,2))),2));
