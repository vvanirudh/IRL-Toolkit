% Transfer learned reward function to a new state space.
function irl_result = firltransfer(prev_result,mdp_data,mdp_model,...
    feature_data,~,verbosity)

% Compute the reward.
r = zeros(mdp_data.states,mdp_data.actions);
tree = prev_result.model_itr{end};
for s=1:mdp_data.states,
    [~,lr] = firlcheckleaf(tree,s,feature_data);
    r(s,:) = lr(1,:);
end;

% Solve MDP.
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Build IRL result.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{tree}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',0,'score',0);
