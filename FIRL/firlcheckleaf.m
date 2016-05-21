% Return the index of the leaf that contains state s in tree.
function [w,r] = firlcheckleaf(tree,s,feature_data)

% Check if this is a leaf.
if tree.type == 0,
    % Return result.
    w = tree.index;
    r = tree.mean;
else
    % Recurse.
    if feature_data.splittable(s,tree.test) == 0,
        branch = tree.ltTree;
    else
        branch = tree.gtTree;
    end;
    [w,r] = firlcheckleaf(branch,s,feature_data);
end;
