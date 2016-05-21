% Solve a standard MDP and return value function, Q function, and policy.
function mdp_solution = standardmdpsolve(mdp_data,r)

% Run value iteration to compute the value function.
v = stdvalueiteration(mdp_data,r);

% Compute Q function and policy.
[q,p] = stdpolicy(mdp_data,r,v);

% Return solution.
mdp_solution = struct('v',v,'q',q,'p',p);
