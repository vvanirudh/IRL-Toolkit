% Compute the closest reward function can be represented by the given tree.
function Rout = firlaveragereward(tree,R,actions)

if tree.type == 0,
    count = length(tree.cells);

    % Replace relevant section of reward function.
    for i=1:count,
        s = tree.cells(i);
        for a=1:actions,
            R(s,a) = tree.mean(a);
        end;
    end;
    Rout = R;
else
    R = firlaveragereward(tree.ltTree,R,actions);
    R = firlaveragereward(tree.gtTree,R,actions);
    Rout = R;
end;
