% Construct the raw features for the objectworld domain.
function [feature_data,true_feature_map,r] = objectworldfeatures(mdp_params,mdp_data)

% mdp_params - definition of MDP domain
% mdp_data - generic definition of domain
% feature_data - generic feature data:
%   splittable - matrix of states to features
%   stateadjacency - sparse state adjacency matrix

% Fill in default parameters.
mdp_params = objectworlddefaultparams(mdp_params);

% Construct adjacency table.
stateadjacency = sparse([],[],[],mdp_data.states,mdp_data.states,...
    mdp_data.states*mdp_data.actions);
for s=1:mdp_data.states,
    for a=1:mdp_data.actions,
        stateadjacency(s,mdp_data.sa_s(s,a,1)) = 1;
    end;
end;

% Construct discrete and continuous split tables.
splittable = zeros(mdp_data.states,(mdp_params.n-1)*(mdp_params.c1+mdp_params.c2));
splittablecont = zeros(mdp_data.states,mdp_params.c1+mdp_params.c2);
for s=1:mdp_data.states,
    % Get x and y positions.
    y = ceil(s/mdp_params.n);
    x = s-(y-1)*mdp_params.n;
    
    % Determine distances to each type of object.
    c1dsq = sqrt(2*(mdp_params.n^2))*ones(mdp_params.c1,1);
    c2dsq = sqrt(2*(mdp_params.n^2))*ones(mdp_params.c2,1);
    for i=1:mdp_params.c1,
        for j=1:length(mdp_data.c1array{i}),
            cy = ceil(mdp_data.c1array{i}(j)/mdp_params.n);
            cx = mdp_data.c1array{i}(j)-(cy-1)*mdp_params.n;
            d = sqrt((cx-x)^2 + (cy-y)^2);
            c1dsq(i) = min(c1dsq(i),d);
        end;
    end;
    for i=1:mdp_params.c2,
        for j=1:length(mdp_data.c2array{i}),
            cy = ceil(mdp_data.c2array{i}(j)/mdp_params.n);
            cx = mdp_data.c2array{i}(j)-(cy-1)*mdp_params.n;
            d = sqrt((cx-x)^2 + (cy-y)^2);
            c2dsq(i) = min(c2dsq(i),d);
        end;
    end;
    
    % Build corresponding feature table (discrete).
    for d=1:mdp_params.n-1,
        strt = (d-1)*(mdp_params.c1+mdp_params.c2);
        for i=1:mdp_params.c1,
            splittable(s,strt+i) = c1dsq(i) < d;
        end;
        strt = (d-1)*(mdp_params.c1+mdp_params.c2)+mdp_params.c1;
        for i=1:mdp_params.c2,
            splittable(s,strt+i) = c2dsq(i) < d;
        end;
    end;
    
    % Build corresponding feature table (continuous).
    splittablecont(s,1:mdp_params.c1) = c1dsq;
    splittablecont(s,mdp_params.c1+1:mdp_params.c1+mdp_params.c2) = c2dsq;
end;

% Return feature data structure.
feature_data = struct('stateadjacency',stateadjacency,'splittable',splittable);

% Construct true feature map.
true_feature_map = sparse([],[],[],mdp_data.states,...
    mdp_params.r_tree.total_leaves,mdp_data.states);
for s=1:mdp_data.states,
    % Determine which leaf state belongs to.
    [leaf,~] = cartcheckleaf(mdp_params.r_tree,s,feature_data);
    true_feature_map(s,leaf) = 1;
end;

% Fill in the reward function.
R_SCALE = 5;
r = cartaverage(mdp_params.r_tree,feature_data)*R_SCALE;

% Optionally, replace splittable.
if mdp_params.continuous,
    feature_data.splittable = splittablecont;
end;
