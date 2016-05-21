% Construct the Gridworld MDP structures. Note that the Gridworld does not
% support transfer tests.
function [mdp_data,r,feature_data,true_feature_map] = gridworldbuild(mdp_params)

% mdp_params - parameters of the gridworld:
%       seed (0) - initialization for random seed
%       n (32) - number of cells along each axis
%       b (4) - size of macro cells
%       determinism (1.0) - probability of correct transition
%       discount (0.9) - temporal discount factor to use
% mdp_data - standard MDP definition structure:
%       states - total number of states in the MDP
%       actions - total number of actions in the MDP
%       discount - temporal discount factor to use
%       sa_s - mapping from state-action pairs to states
%       sa_p - mapping from state-action pairs to transition probabilities
% r - mapping from state-action pairs to rewards

% Fill in default parameters.
mdp_params = gridworlddefaultparams(mdp_params);

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

% Create MDP data structure.
mdp_data = struct(...
    'states',mdp_params.n^2,...
    'actions',5,...
    'discount',mdp_params.discount,...
    'determinism',mdp_params.determinism,...
    'sa_s',sa_s,...
    'sa_p',sa_p);

% Fill in the reward function.
R_SCALE = 100;
r = zeros(mdp_params.n^2,5);
for yc=1:mdp_params.n/mdp_params.b,
    for xc=1:mdp_params.n/mdp_params.b,
        % Select a reward for macro-cell.
        macro_reward = (rand(1,1).^8)*R_SCALE;
        
        % Assign reward to all state-action pairs in macro-cell.
        for y=(yc-1)*mdp_params.b+1:yc*mdp_params.b,
            for x=(xc-1)*mdp_params.b+1:xc*mdp_params.b,
                r((y-1)*mdp_params.n+x,:) = repmat(macro_reward,1,5);
            end;
        end;
    end;
end;

% Build the features.
[feature_data,true_feature_map] = gridworldfeatures(mdp_params,mdp_data);
