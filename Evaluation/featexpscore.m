% Compute the feature expectation distance of the true features between the
% true policy and the learned policy.
function score = featexpscore(mdp_soln,~,irl_soln,~,~,true_feature_map,...
    mdp_data,~,model)

% Compute occupancies measures for IRL result and true policy.
om_irl = feval(strcat(model,'frequency'),mdp_data,irl_soln);
om_mdp = feval(strcat(model,'frequency'),mdp_data,mdp_soln);

% Compute feature expectations.
feature_exp_irl = true_feature_map'*om_irl;
feature_exp_mdp = true_feature_map'*om_mdp;

% Compute score as expectation distance.
score = norm(feature_exp_irl-feature_exp_mdp)*(1-mdp_data.discount);
