% Transfer learned reward function to a new state space.
function irl_result = antransfer(prev_result,mdp_data,mdp_model,...
    feature_data,true_feature_map,verbosity)

% Get weigths.
wts = prev_result.model_itr{end};

% Decide if we want true features.
if length(wts) == size(true_feature_map,2),
    % Use true features.
    F = true_feature_map;
elseif length(wts) == size(feature_data.splittable,2)+1,
    % Use all features.
    F = feature_data.splittable;
    % Add dummy feature.
    F = horzcat(F,ones(mdp_data.states,1));
else
    % Trying to transfer without features - just use identity.
    F = eye(mdp_data.states);
end;

% Compute reward.
r = repmat(F*wts,1,mdp_data.actions);

% Solve MDP.
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Build IRL result.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{wts}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',0,'score',0);
