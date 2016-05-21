% Dvijotham & Todorov OptV implementation for stochastic MDP.
function irl_result = optvrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_features,verbosity)

% algorithm_params - parameters of the FIRL algorithm:
%       seed (0) - initialization for random seed
% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       time - total running time

% IMPORTANT: This is an experimental implementation that does not use
% reward features, since the algorithm learns value functions directly
% rather than reward functions. Therefore, this implementation will not be
% able to perform transfer, and since state indicators are used for value
% function features, the algorithm will often produce a worse result than
% the other IRL methods in this implementation.

% Fill in default parameters.
algorithm_params = optvdefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);

% Initialize variables.
[states,actions,transitions] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% Compute state-action expectations.
muE = zeros(states,actions);
ex_s = zeros(N,T);
ex_a = zeros(N,T);
for i=1:N,
    for t=1:T,
        ex_s(i,t) = example_samples{i,t}(1);
        ex_a(i,t) = example_samples{i,t}(2);
        muE(ex_s(i,t),ex_a(i,t)) = muE(ex_s(i,t),ex_a(i,t)) + 1;
    end;
end;

% Create anonymous function.
fun = @(v)optvdiscounted(v,muE,ex_s,ex_a,mdp_data);

% Set up optimization options.
options = struct();
options.Display = 'iter';
options.LS_init = 2;
options.LS = 2;
options.Method = 'lbfgs';
%options.DerivativeCheck = 'on';
if verbosity == 0,
    options.display = 'none';
end;

tic;

v = minFunc(fun,zeros(states,1),options);

time = toc;
if verbosity ~= 0,
    fprintf(1,'Optimization completed in %f seconds.\n',time);
end;

% Compute reward.
q = mdp_data.discount*sum(mdp_data.sa_p.*v(mdp_data.sa_s),3);
r = repmat(v - maxentsoftmax(q),1,actions);
r_itr = {r};
tree_r_itr = {r};

% Compute policies.
soln = mdp_solve(mdp_data,r_itr{1});
p_itr{1} = soln.p;
tree_p_itr{1} = p_itr{1};
v = soln.v;
q = soln.q;
p = soln.p;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'r_itr',{r_itr},...
    'tree_r_itr',{tree_r_itr},'p_itr',{p_itr},'tree_p_itr',{tree_p_itr},...
    'time',time);
