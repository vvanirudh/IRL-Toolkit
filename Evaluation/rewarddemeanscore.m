% Compute distance to true reward with mean-matching.
function score = rewarddemeanscore(~,mdp_r,~,irl_r,~,~,~,~,~)

mdp_r = bsxfun(@minus,mean(mdp_r,2),mean(mean(mdp_r,2),1));
irl_r = bsxfun(@minus,mean(irl_r,2),mean(mean(irl_r,2),1));
score = norm(mdp_r-irl_r);
