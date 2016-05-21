% Compute distance to true reward with first moment matching.
function score = rewardmomentmatchscore(~,mdp_r,~,irl_r,~,~,~,~,~)

mdp_r = bsxfun(@minus,mean(mdp_r,2),mean(mean(mdp_r,2),1));
irl_r = bsxfun(@minus,mean(irl_r,2),mean(mean(irl_r,2),1));
if std(mdp_r) ~= 0,
    mdp_r = mdp_r/std(mdp_r);
end;
if std(irl_r) ~= 0,
    irl_r = irl_r/std(irl_r);
end;
score = norm(mdp_r-irl_r);
