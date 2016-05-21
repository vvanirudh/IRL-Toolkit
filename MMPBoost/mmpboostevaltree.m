function val = mmpboostevaltree(tree,s,F)

% Check if this is a leaf.
if tree.type == 0,
    % Return result.
    val = tree.mean;
else
    % Recurse.
    if F(s,tree.test) == 0,
        branch = tree.ltTree;
    else
        branch = tree.gtTree;
    end;
    val = mmpboostevaltree(branch,s,F);
end;
