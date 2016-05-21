% Return average reward for given regression tree.
function R = cartaverage(tree,feature_data)

if tree.type == 0,
    % Simply return the average.
    R = repmat(tree.mean,size(feature_data.splittable,1),1);
else
    % Compute reward on each side.
    ltR = cartaverage(tree.ltTree,feature_data);
    gtR = cartaverage(tree.gtTree,feature_data);
    
    % Combine.
    ind = repmat(feature_data.splittable(:,tree.test),1,size(ltR,2));
    R = (1-ind).*ltR + ind.*gtR;
end;
