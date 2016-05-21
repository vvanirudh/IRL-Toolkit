% Compute the expected sum of discounted rewards when acting according to
% each policy.
function score = valuescore(mdp_soln,mdp_r,irl_soln,~,~,~,...
    mdp_data,~,model)

% Compute occupancies measures for IRL result and true policy.
om_irl = feval(strcat(model,'frequency'),mdp_data,irl_soln);
om_mdp = feval(strcat(model,'frequency'),mdp_data,mdp_soln);

% Compute feature expectations.
feature_exp_irl = om_irl'*mean(mdp_r,2);
feature_exp_mdp = om_mdp'*mean(mdp_r,2);

% Compute score as expectation distance.
score = [feature_exp_mdp-feature_exp_irl; feature_exp_irl; feature_exp_mdp];
