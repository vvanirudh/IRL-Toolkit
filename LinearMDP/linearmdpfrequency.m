% Compute the occupancy measure of the linear MDP given a policy.
function D = linearmdpfrequency(mdp_data,mdp_solution,initD,prevD)

[states,actions,transitions] = size(mdp_data.sa_p);
VITR_THRESH = 1e-4;
%VITR_THRESH = 1e-10;

if nargin >= 4,
    D = prevD;
else
    D = zeros(states,1);
end;

if nargin < 3 || isempty(initD),
    % Initialize uniform initial state distribution.
    initD = (1/states)*ones(states,1);
end;

diff = 1.0;
while diff >= VITR_THRESH,
    Dp = D;
    Dpi = repmat(mdp_solution.p,[1 1 transitions]).*mdp_data.sa_p.*...
        repmat(Dp,[1 actions transitions])*mdp_data.discount;
    D = initD + sum(sparse(mdp_data.sa_s(:),1:states*actions*transitions,...
        Dpi(:),states,states*actions*transitions)*ones(states*actions*transitions,1),2);
    diff = max(abs(D-Dp));
end;
