% Run value iteration to solve a linear MDP.
function [v,q,p,logp] = linearvalueiteration(mdp_data,r,vinit)

states = mdp_data.states;
actions = mdp_data.actions;
VITR_THRESH = 1e-4;
%VITR_THRESH = 1e-10;

% Compute log state partition function V.
if (nargin == 3)
    v = vinit;
else
    v = zeros(states,1);
end;
diff = 1.0;
while diff >= VITR_THRESH,
    % Initialize new v.
    vp = v;
    
    % Compute q function.
    q = r + mdp_data.discount*sum(mdp_data.sa_p.*vp(mdp_data.sa_s),3);
    
    % Compute softmax.
    v = maxentsoftmax(q);
    
    diff = max(abs(v-vp));
end;

% Compute policy.
logp = q - repmat(v,1,actions);
p = exp(logp);
