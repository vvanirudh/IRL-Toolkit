% Given reward and value functions, solve for q function and policy.
function [q,p] = stdpolicy(mdp_data,r,v)

% Compute Q function.
q = r + sum(mdp_data.sa_p.*v(mdp_data.sa_s),3)*mdp_data.discount;

% Compute policy.
[~,p] = max(q,[],2);
