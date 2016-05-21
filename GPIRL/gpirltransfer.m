% Transfer learned reward function to a new state space.
function irl_result = gpirltransfer(prev_result,mdp_data,mdp_model,...
    feature_data,~,verbosity)

% To transfer the result to the new state space, we must first compute
% alpha for the old state space.
gp = prev_result.model_itr{end};
[Kstar,~,alpha] = gpirlkernel(gp,gp.Y,feature_data.splittable);

% Compute reward on new state space.
r = repmat(Kstar'*alpha,1,mdp_data.actions);

% Solve MDP.
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Build IRL result.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{gp}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',0,'score',0);
