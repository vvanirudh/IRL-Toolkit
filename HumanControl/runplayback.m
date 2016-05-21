% Play back some samples from an IRL solution and the original policy
% side-by-side.
function runplayback(test_result,initial_state,show_true_reward,...
    use_true_reward,mdp_model,steps)

% Choose reward.
if use_true_reward,
    r = test_result.true_r;
else
    r = test_result.irl_result.r;
end;
if show_true_reward,
    sr = test_result.true_r;
else
    sr = test_result.irl_result.r;
end;
% Compute policy.
soln = feval(strcat(mdp_model,'solve'),test_result.mdp_data,r);

% Open window.
figure(1);
set(gcf,'Position',[20 200 800 800]);
feval(strcat(test_result.mdp,'draw'),sr,[],[],test_result.mdp_params,test_result.mdp_data);

% Run simulation.
s = initial_state;
agent_fig = feval(strcat(test_result.mdp,'drawhuman'),test_result.mdp_params,test_result.mdp_data,s);
for t=1:steps,
    % Choose action.
    a = feval(strcat(mdp_model,'action'),test_result.mdp_data,soln,s);
    % Execute action.
    samp = rand(1,1);
    csum = 0;
    for k=1:size(test_result.mdp_data.sa_p,3),
        csum = csum + test_result.mdp_data.sa_p(s,a,k);
        if csum >= samp,
            s = test_result.mdp_data.sa_s(s,a,k);
            break;
        end;
    end;
    % Update agent.
    feval(strcat(test_result.mdp,'movehuman'),test_result.mdp_params,...
            test_result.mdp_data,s,agent_fig);
    % Pause.
    pause(0.2);
end;
