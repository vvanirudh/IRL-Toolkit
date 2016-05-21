% Take a single step with the specified action.
function s = standardmdpstep(mdp_data,~,s,a)

% Random sample for stochastic step.
r = rand(1,1);
sm = 0;
for k=1:size(mdp_data.sa_p,3),
    sm = sm+mdp_data.sa_p(s,a,k);
    if sm >= r,
        s = mdp_data.sa_s(s,a,k);
        return;
    end;
end;

% Should never reach here.
fprintf(1,'ERROR: MDP data specifies transition distribution for state %i action %i that does not sum to 1!\n',...
    s,a);
s = -1;
