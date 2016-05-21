% Compute the probability of speeding near police.
function score = policescore(mdp_soln,~,irl_soln,~,feature_data,~,...
    mdp_data,mdp_params,model)

% Compute occupancies measures for IRL result and true policy.
om_irl = feval(strcat(model,'frequency'),mdp_data,irl_soln);
om_mdp = feval(strcat(model,'frequency'),mdp_data,mdp_soln);

% Precompute police features.
mdp_params = highwaydefaultparams(mdp_params);
speeds = mdp_params.speeds;
lanes = mdp_params.lanes;
c1 = mdp_params.c1;
c2 = mdp_params.c2;
pf = speeds+lanes+(c1+c2)*8*6+1+9;
pb = speeds+lanes+(c1+c2)*8*7+1+9;

% Now compute probability of speeding near police.
probs_irl = zeros(2,1);
probs_mdp = zeros(2,1);
if mdp_params.continuous,
    splittable = feature_data.altsplittable;
else
    splittable = feature_data.splittable;
end;
for s=1:mdp_data.states,
    % Check to see if the police features hold.
    if splittable(s,pf) || splittable(s,pb),
        police = 1;
    else
        police = 0;
    end;
    % Check to see if the speed features hold.
    if splittable(s,3),
        speeding = 1;
    else
        speeding = 0;
    end;
    speeding = (speeding & police) + 1;
    % Set probability.    
    probs_irl(speeding) = probs_irl(speeding) + om_irl(s);
    probs_mdp(speeding) = probs_mdp(speeding) + om_mdp(s);
end;
probs_irl = probs_irl/sum(probs_irl);
probs_mdp = probs_mdp/sum(probs_mdp);

% Return speed.
score = [probs_irl(2)/probs_mdp(2);probs_irl(2);probs_mdp(2)];
