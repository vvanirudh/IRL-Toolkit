% Visualize MDP state space with given IRL test solution.
function visualize(test_result,suppress_intermediate)

if nargin == 1,
    suppress_intermediate = 0;
end;

% Compute visible examples.
Eo = zeros(test_result.mdp_data.states,1);
for i=1:size(test_result.example_samples,1),
    for t=1:size(test_result.example_samples,2),
        Eo(test_result.example_samples{i,t}(1)) = 1;
    end;
end;
g = ones(test_result.mdp_data.states,1)*0.5+Eo*0.5;

% Create figure.
w = 1200;
h = 600;

if ~suppress_intermediate,
    % Draw intermediate results.
    if isfield(test_result.irl_result,'r_itr'),
        num_itr = length(test_result.irl_result.r_itr);
        for i=1:num_itr,
            % Create intermediate figure.
            figure('Position',[20 200 w h]);
            hold on;
            grid on;
            cla;

            % On the left side, draw optimization result.
            subplot(1,2,1);
            feval(strcat(test_result.mdp,'draw'),test_result.irl_result.r_itr{i},...
                test_result.irl_result.p_itr{i},g,test_result.mdp_params,test_result.mdp_data);

            % On the right side, draw fitting result.
            subplot(1,2,2);
            if isfield(test_result.irl_result,'model_itr'),
                feval(strcat(test_result.mdp,'draw'),test_result.irl_result.model_r_itr{i},...
                    test_result.irl_result.model_p_itr{i},g,...
                    test_result.mdp_params,test_result.mdp_data,...
                    test_result.feature_data,test_result.irl_result.model_itr{i});
            else
                feval(strcat(test_result.mdp,'draw'),test_result.irl_result.r_itr{i},...
                    test_result.irl_result.p_itr{i},g,...
                    test_result.mdp_params,test_result.mdp_data);
            end;

            % Turn hold off.
            hold off;
        end;
    end;
end;

% Create final figure.
figure('Position',[20 200 w h]);
hold on;
grid on;
cla;

% Draw reward for ground truth.
subplot(1,2,1);
feval(strcat(test_result.mdp,'draw'),test_result.true_r,...
    test_result.mdp_solution.p,g,test_result.mdp_params,test_result.mdp_data);

% Draw reward for IRL result.
subplot(1,2,2);
feval(strcat(test_result.mdp,'draw'),test_result.irl_result.r,...
    test_result.irl_result.p,g,test_result.mdp_params,test_result.mdp_data);

% Turn hold off.
hold off;
