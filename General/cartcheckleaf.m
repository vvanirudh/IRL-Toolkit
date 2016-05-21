% Check which leaf of tree contains leaf.
function [leaf,val] = cartcheckleaf(tree,s,feature_data)

% Check if this is a leaf.
if tree.type == 0,
    % Return result.
    leaf = tree.index;
    val = tree.mean;
else
    % Recurse.
    if feature_data.splittable(s,tree.test) == 0,
        branch = tree.ltTree;
    else
        branch = tree.gtTree;
    end;
    [leaf,val] = cartcheckleaf(branch,s,feature_data);
end;

