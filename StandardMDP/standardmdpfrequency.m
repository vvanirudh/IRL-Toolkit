% Compute the occupancy measure of the MDP given a policy.
function x = standardmdpfrequency(mdp_data,mdp_solution)

% Build flow constraint matrix.
A = sparse([],[],[],mdp_data.states,mdp_data.states,...
    mdp_data.states*size(mdp_data.sa_p,3));
for s=1:mdp_data.states,
    A(s,s) = A(s,s)+1;
    a = mdp_solution.p(s);
    for k=1:size(mdp_data.sa_p,3),
        sp = mdp_data.sa_s(s,a,k);
        A(sp,s) = A(sp,s) - mdp_data.discount*mdp_data.sa_p(s,a,k);
    end;
end;

% Solve linear system to get occupancy measure.
x = A\((1/mdp_data.states)*ones(mdp_data.states,1));
