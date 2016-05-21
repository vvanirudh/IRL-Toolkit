% Build matrices for optimization phase from fitted feature tree.
function [ProjToLeaf,LeafToProj,FeatureMatch] = firlprojectionfromtree(...
    tree,leaves,states,actions,feature_data);

% Constants.
DEPTH_WEIGHT = 1;

% Matrix of adjacencies.
adjleaves = sparse(leaves,leaves);
stateleaves = zeros(states,1);

% Count number of elements in each leaf and assign leaf to each state.
elements = zeros(leaves,1);
for s=1:states,
    leaf = firlcheckleaf(tree,s,feature_data);
    elements(leaf,1) = elements(leaf,1) + 1;
    stateleaves(s,1) = leaf;
end;

% Count pairs and build adjacency matrix.
pairs = 0;
for s=1:states,
    leaf = stateleaves(s,1);
    adj = find(feature_data.stateadjacency(s,:));
    numadj = length(adj);
    
    % Write out adjacencies.
    for i=1:numadj,
        lother = stateleaves(adj(i),1);
        if lother ~= leaf,
            % Found adjacency.
            if adjleaves(lother,leaf) == 0 && adjleaves(leaf,lother) == 0,
                pairs = pairs + 1;
            end;
            adjleaves(lother,leaf) = 1;
            adjleaves(leaf,lother) = 1;
        end;
    end;
end;

% Construct feature match matrix.
FeatureMatch = sparse(pairs,leaves);
idx = 1;
maxPair = 0;
for l1=1:leaves,
    for l2=l1+1:leaves,
        adjacent = adjleaves(l1,l2);
        if adjacent > 0,
            matchDepth = (firlmatchdepth(tree,l1,l2)-1);
            FeatureMatch(idx,l1) = adjacent+matchDepth*DEPTH_WEIGHT;
            FeatureMatch(idx,l2) = -adjacent-matchDepth*DEPTH_WEIGHT;
            if (FeatureMatch(idx,l1) > maxPair),
                maxPair = FeatureMatch(idx,l1);
            end;
            idx = idx+1;
        end;
    end;
end;
if pairs <= 0,
    % Handle degeneracy.
    FeatureMatch = sparse(1,leaves);
else
    FeatureMatch = FeatureMatch./maxPair;
end;

% Construct projection matrix.
ProjToLeaf = sparse(leaves,states*actions);
LeafToProj = sparse(states*actions,leaves);
for s=1:states,
    leaf = stateleaves(s);
    for a=1:actions,
        pos = (s-1)*actions+a;
        ProjToLeaf(leaf,pos) = 1/(elements(leaf,1)*actions);
        LeafToProj(pos,leaf) = 1;
    end;
end;
