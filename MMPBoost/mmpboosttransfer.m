% Transfer learned reward function to a new state space.
function irl_result = mmpboosttransfer(prev_result,mdp_data,mdp_model,...
    feature_data,true_feature_map,verbosity)

% Get latest model.
wts = prev_result.model_itr{end}.wts;
F = feature_data.splittable(:,prev_result.model_itr{end}.initial_indices);
F = horzcat(F,ones(mdp_data.states,1));

% Get all boosted features.
for i=1:length(prev_result.model_itr{end}.added_trees),
    newCol = zeros(mdp_data.states,1);
    for s=1:mdp_data.states,
        newCol(s,1) = mmpboostevaltree(prev_result.model_itr{end}.added_trees{i},s,F);
    end;
    F = horzcat(F,newCol);
end;

% Compute reward.
r = repmat(F*wts,1,mdp_data.actions);

% Solve MDP.
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Build IRL result.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{prev_result.model_itr{end}}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',0,'score',0);
