% Compute variance in the IRL reward within the true features.
function score = featvarscore(~,~,~,irl_r,~,true_feature_map,~,~,~)

% Compute sum of standard deviations in each feature.
score = 0;
r = mean(irl_r,2);
for f=1:size(true_feature_map,2),
    rf = r(true_feature_map(:,f) ~= 0);
    if ~isempty(rf),
        score = score + std(rf);
    end;
end;

% Normalize by number of features.
score = score/size(true_feature_map,2);

% Normalize by standard deviation of reward.
score = score/(std(mean(irl_r,2)));
