% Compute the probability of taking a different action from the correct
% policy.
function score = mispredictionscore(mdp_soln,~,irl_soln,~,~,~,mdp_data,~,...
    model)

mdp_p = mdp_soln.p;
irl_p = irl_soln.p;

% Compute misprediction for IRL policy.
score = feval(strcat(model,'compare'),mdp_p,irl_p)/mdp_data.states;

% Compute misprediction for true policy.
truth = feval(strcat(model,'compare'),mdp_p,mdp_p)/mdp_data.states;

% Return difference and all three other scores.
score = [score-truth;score;truth];
