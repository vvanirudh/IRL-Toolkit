% Compute the average expected speed.
function score = speedscore(mdp_soln,~,irl_soln,~,~,~,...
    mdp_data,mdp_params,model)

% Compute occupancies measures for IRL result and true policy.
om_irl = feval(strcat(model,'frequency'),mdp_data,irl_soln);
om_mdp = feval(strcat(model,'frequency'),mdp_data,mdp_soln);

% Now use the occupancy measures to determine the probability of having
% each speed.
mdp_params = highwaydefaultparams(mdp_params);
probs_irl = zeros(mdp_params.speeds,1);
probs_mdp = zeros(mdp_params.speeds,1);
for s=1:mdp_data.states,
    [~,~,speed] = highwaystatetocoord(s,mdp_params);
    probs_irl(speed) = probs_irl(speed) + om_irl(s);
    probs_mdp(speed) = probs_mdp(speed) + om_mdp(s);
end;
probs_irl = probs_irl/sum(probs_irl);
probs_mdp = probs_mdp/sum(probs_mdp);
speed_irl = [1:mdp_params.speeds]*probs_irl;
speed_mdp = [1:mdp_params.speeds]*probs_mdp;

% Return speed.
score = [speed_irl/speed_mdp;speed_irl;speed_mdp];
