% Sample example tranjectories from the state space of a given MDP.
function example_samples = sampleexamples(mdp_model,mdp_data,mdp_solution,test_params)

% Allocate training samples.
N = test_params.training_samples;
T = test_params.training_sample_lengths;
example_samples = cell(N,T);

% Sample trajectories.
for i=1:N,
    % Sample initial state.
    s = ceil(rand(1,1)*mdp_data.states);
    
    % Run sample trajectory.
    for t=1:T,
        % Compute optimal action for current state.
        a = feval(strcat(mdp_model,'action'),mdp_data,mdp_solution,s);
        
        % Store example.
        example_samples{i,t} = [s;a];
        
        % Move on to next state.
        s = feval(strcat(mdp_model,'step'),mdp_data,mdp_solution,s,a);
    end;
end;
