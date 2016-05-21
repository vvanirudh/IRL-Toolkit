% Pre-compute statistics from examples for GPIRL.
function [mu_sa,init_s] = gpirlgetstatistics(example_samples,mdp_data)

% Constants.
[states,actions,transitions] = size(mdp_data.sa_s);
[N,T] = size(example_samples);

% Compute expectations.
mu_sa = zeros(states,actions);
init_s = zeros(states,1);
for i=1:N,
    for t=1:T,
        s = example_samples{i,t}(1);
        a = example_samples{i,t}(2);
        
        % Add to state action and state expectations.
        mu_sa(s,a) = mu_sa(s,a) + 1;
        init_s(s) = init_s(s) + 1;
        
        % Subtract off probabilities of transitioning to other states.
        % See notes on computing state visitation counts for details of
        % what's going on here.
        % This is the - \sum_{i,t} \gamma P(s_j | s_it, a_it) term.
        for k=1:transitions,
            sp = mdp_data.sa_s(s,a,k);
            init_s(sp) = init_s(sp) - mdp_data.discount*mdp_data.sa_p(s,a,k);
        end;
    end;
end;
