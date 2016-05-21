% Solve a linear MDP and return value function, Q function, and policy.
function mdp_solution = linearmdpsolve(mdp_data,r)

% Run value iteration to compute the value function and policy.
[v,q,p] = linearvalueiteration(mdp_data,r);

% Return solution.
mdp_solution = struct('v',v,'q',q,'p',p);
