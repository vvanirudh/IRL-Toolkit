% Compute distance to true reward.
function score = rewardscore(~,mdp_r,~,irl_r,~,~,~,~,~)

score = norm(mean(mdp_r,2)-mean(irl_r,2));
