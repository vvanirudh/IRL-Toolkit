% Compute distance between the expected frequency of taking each action in
% each state.
function score = policydistscore(mdp_soln,~,irl_soln,~,~,~,mdp_data,~,~)

% Make sure both policies are probabilities.
mdp_p = mdp_soln.p;
irl_p = irl_soln.p;
if size(mdp_p,2) == 1,
    mdp_p = zeros(mdp_data.states,mdp_data.actions);
    mdp_p(sub2ind(size(mdp_p),[1:mdp_data.states]',mdp_soln.p)) = 1;
end;
if size(irl_p,2) == 1,
    irl_p = zeros(mdp_data.states,mdp_data.actions);
    irl_p(sub2ind(size(irl_p),[1:mdp_data.states]',irl_soln.p)) = 1;
end;

% Return score.
score = sum(sum(abs(mdp_p-irl_p)))*(0.5/mdp_data.states);
