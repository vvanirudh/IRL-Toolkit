% Launch the human-driven example generation.
function human_trial = runhumantrial(mdp,mdp_params,test_params)

% mdp - string specifying example to test on.
% mdp_params - string specifying parameters of example.
% test_params - parameters for human trial (see humantrialdefaultparams.m)

% Make sure relevant paths are added.
addpaths;

% Set default test parameters.
test_params = humantrialdefaultparams(test_params);
mdp_params = feval(strcat(mdp,'defaultparams'),mdp_params);

% Construct MDP and features.
[mdp_data,r,~,~] = feval(strcat(mdp,'build'),mdp_params);

% Create global example trace.
global trace;
global trace_params;
trace = cell(test_params.training_samples,test_params.training_sample_lengths);
trace_params = test_params;
trace_params.r = r;
trace_params.mdp_data = mdp_data;
trace_params.mdp_params = mdp_params;
trace_params.mdp = mdp;
trace_params.step = [1 1];
trace_params.state = ceil(rand(1,1)*mdp_data.states);

% Open window.
figure(1);
set(gcf,'Position',[20 20 800 1000]);
feval(strcat(mdp,'draw'),r,[],[],mdp_params,mdp_data);

% Create UI.
% Printout of current step.
trace_params.label = ...
    uicontrol('Style', 'text', ...
              'String', ['step 1/' num2str(test_params.training_sample_lengths) ' path 1/' num2str(test_params.training_samples)], ...
              'units', 'normalized', ...
              'position', [0.05 0.9 0.2 0.05]);
          
% Buttons for each action.
[names,keys,order] = feval(strcat(mdp,'getactionnames'),mdp_params);
for i=1:length(order),
    % Create button.
    uicontrol('Parent', gcf, ...
        'Units','normalized', ...
        'Callback',['humantrialcallback(''action'',' num2str(order(i)) ')'], ...
        'Position',[0.05 0.9-0.05*i 0.2 0.05], ...
        'String',[names{order(i)} ' (' keys{order(i)} ')']);
    % Store key for callback.
    trace_params.keys{order(i)} = keys{order(i)};
end;
trace_params.undo = 'u';

% Hook up callback for keyboard presses.
set(gcf, 'KeyPressFcn', @humantrialkeycallback);

% Draw previous trial traces.
if ~isempty(trace_params.previous_trial),
    for i=1:size(trace_params.previous_trial,1),
        for t=1:size(trace_params.previous_trial,2),
            s = trace_params.previous_trial{i,t}(1);
            a = trace_params.previous_trial{i,t}(2);
            feval(strcat(mdp,'drawhuman'),mdp_params,mdp_data,s,a);
        end;
    end;
end;

% Draw agent.
trace_params.agent_fig = feval(strcat(mdp,'drawhuman'),mdp_params,mdp_data,trace_params.state);

% Wait until termination.
waitfor(gcf);

% Return result.
human_trial = struct('example_samples',{trace},'mdp_params',mdp_params);

% Clean up.
clear global trace;
clear global trace_params;
