% Construct the raw features for the gridworld domain.
function [feature_data,true_feature_map] = gridworldfeatures(mdp_params,mdp_data)

% mdp_params - definition of MDP domain
% mdp_data - generic definition of domain
% feature_data - generic feature data:
%   splittable - matrix of states to features
%   stateadjacency - sparse state adjacency matrix

% Fill in default parameters.
mdp_params = gridworlddefaultparams(mdp_params);

% Construct adjacency table.
stateadjacency = sparse([],[],[],mdp_data.states,mdp_data.states,...
    mdp_data.states*mdp_data.actions);
for s=1:mdp_data.states,
    for a=1:mdp_data.actions,
        stateadjacency(s,mdp_data.sa_s(s,a,1)) = 1;
    end;
end;

% Construct split table.
splittable = zeros(mdp_data.states,(mdp_params.n-1)*2);
for y=1:mdp_params.n,
    for x=1:mdp_params.n,
        % Compute x and y split tables.
        xtable = horzcat(zeros(1,x-1),ones(1,mdp_params.n-x));
        ytable = horzcat(zeros(1,y-1),ones(1,mdp_params.n-y));
        splittable((y-1)*mdp_params.n+x,:) = horzcat(xtable,ytable);
    end;
end;

% Return feature data structure.
feature_data = struct('stateadjacency',stateadjacency,'splittable',splittable);

% Construct true feature map.
true_feature_map = sparse([],[],[],mdp_data.states,...
    mdp_data.states/(mdp_params.b^2),mdp_data.states);
for y=1:mdp_params.n,
    for x=1:mdp_params.n,
        cx = ceil(x/mdp_params.b);
        cy = ceil(y/mdp_params.b);
        feat = (cy-1)*(mdp_params.n/mdp_params.b)+cx;
        true_feature_map((y-1)*mdp_params.n+x,feat) = 1;
    end;
end;
