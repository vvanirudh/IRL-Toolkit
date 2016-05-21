% Run value iteration to solve a standard MDP.
function v = stdvalueiteration(mdp_data,r,vinit)

% Allocate initial value function & variables.
diff = 1.0;
if (nargin == 3)
    vn = vinit;
else
    vn = zeros(mdp_data.states,1);
end;

% Perform value iteration.
while diff >= 0.0001,
    vp = vn;
    vn = max(r + sum(mdp_data.sa_p.*vp(mdp_data.sa_s),3)*mdp_data.discount,[],2);
    diff = max(abs(vn-vp));
end;

% Return value function.
v = vn;
