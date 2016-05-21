% Construct the Objectworld MDP structures.
function [mdp_data,r,feature_data,true_feature_map] = objectworldbuild(mdp_params)

% mdp_params - parameters of the objectworld:
%       seed (0) - initialization for random seed
%       n (32) - number of cells along each axis
%       placement_prob (0.05) - probability of placing object in each cell
%       c1 (2) - number of primary "colors"
%       c2 (2) - number of secondary "colors"
%       determinism (1.0) - probability of correct transition
%       discount (0.9) - temporal discount factor to use
% mdp_data - standard MDP definition structure with object-world details:
%       states - total number of states in the MDP
%       actions - total number of actions in the MDP
%       discount - temporal discount factor to use
%       sa_s - mapping from state-action pairs to states
%       sa_p - mapping from state-action pairs to transition probabilities
%       map1 - mapping from states to c1 colors
%       map2 - mapping from states to c2 colors
%       c1array - array of locations by c1 colors
%       c2array - array of locations by c2 colors
% r - mapping from state-action pairs to rewards

% Fill in default parameters.
mdp_params = objectworlddefaultparams(mdp_params);

% Set random seed.
rand('seed',mdp_params.seed);

% Build action mapping.
sa_s = zeros(mdp_params.n^2,5,5);
sa_p = zeros(mdp_params.n^2,5,5);
for y=1:mdp_params.n,
    for x=1:mdp_params.n,
        s = (y-1)*mdp_params.n+x;
        successors = zeros(1,1,5);
        successors(1,1,1) = s;
        successors(1,1,2) = (min(mdp_params.n,y+1)-1)*mdp_params.n+x;
        successors(1,1,3) = (y-1)*mdp_params.n+min(mdp_params.n,x+1);
        successors(1,1,4) = (max(1,y-1)-1)*mdp_params.n+x;
        successors(1,1,5) = (y-1)*mdp_params.n+max(1,x-1);
        sa_s(s,:,:) = repmat(successors,[1,5,1]);
        sa_p(s,:,:) = reshape(eye(5,5)*mdp_params.determinism + ...
            (ones(5,5)-eye(5,5))*((1.0-mdp_params.determinism)/4.0),...
            1,5,5);
    end;
end;

% Construct map.
map1 = zeros(mdp_params.n^2,1);
map2 = zeros(mdp_params.n^2,1);
c1array = cell(mdp_params.c1,1);
c2array = cell(mdp_params.c2,1);
% Place objects in "rounds", with 2 colors each round.
% This ensures, for example, that increasing c1 from 2 to 4 results in all
% of the objects from c1=2 being placed, plus additional "distractor"
% objects. This prevents the situation when c1 is high of not placing any
% objects with c1=1 or c1=2 (which makes the example useless for trying to
% infer any meaningful reward).
for round=1:ceil(mdp_params.c1*0.5),
    initc1 = (round-1)*2;
    if initc1+1 == mdp_params.c1,
        % Always choose the leftover c1.
        prob = mdp_params.placement_prob*0.5;
        maxc1 = 1;
    else
        % Choose from two c1 colors.
        prob = mdp_params.placement_prob;
        maxc1 = 2;
    end;
    for s=1:mdp_params.n^2,
        if rand(1,1) < prob && map1(s) == 0,
            % Place object.
            c1 = initc1+ceil(rand(1,1)*maxc1);
            c2 = ceil(rand(1,1)*mdp_params.c2);
            map1(s) = c1;
            map2(s) = c2;
            c1array{c1} = [c1array{c1};s];
            c2array{c2} = [c2array{c2};s];
        end;
    end;
end;

% Create MDP data structure.
mdp_data = struct(...
    'states',mdp_params.n^2,...
    'actions',5,...
    'discount',mdp_params.discount,...
    'determinism',mdp_params.determinism,...
    'sa_s',sa_s,...
    'sa_p',sa_p,...
    'map1',map1,...
    'map2',map2,...
    'c1array',{c1array},...
    'c2array',{c2array});

% Construct feature map.
[feature_data,true_feature_map,r] = objectworldfeatures(mdp_params,mdp_data);
