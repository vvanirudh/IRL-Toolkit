% Determine depth of first common parent of two leaves.
function matchDepth = firlmatchdepth(tree,l1,l2)

% Check if both leaves match.
if tree.type == 0,
    if tree.index == l1,
        matchDepth = -1;
    elseif tree.index == l2,
        matchDepth = -2;
    else
        matchDepth = 0;
    end;
else
    mLeft = firlmatchdepth(tree.ltTree,l1,l2);
    mRight = firlmatchdepth(tree.gtTree,l1,l2);
    if (mLeft == -1 || mLeft == -2) && mRight == 0,
        matchDepth = mLeft;
    elseif (mRight == -1 || mRight == -2) && mLeft == 0,
        matchDepth = mRight;
    elseif (mRight == -1 && mLeft == -2) || (mRight == -2 && mLeft == -1),
        matchDepth = 1;
    else
        matchDepth = max(mLeft,mRight);
        if matchDepth > 0,
            matchDepth = matchDepth+1;
        end;
    end;
end;
