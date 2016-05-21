% Ziebart's Maximum Entropy IRL, with optional prior on reward values.
function irl_result = maxentrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_features,verbosity)

% algorithm_params - parameters of the FIRL algorithm:
%       seed (0) - initialization for random seed
%       laplace_prior (0) - use Laplace prior for regularization
%       true_features (0) - use true features as a basis
%       all_features (1) - use the provided features as a basis
% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       time - total running time

% Fill in default parameters.
algorithm_params = maxentdefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);

% Initialize variables.
[states,actions,transitions] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% Build feature membership matrix.
if algorithm_params.all_features,
    F = feature_data.splittable;
    % Add dummy feature.
    F = horzcat(F,ones(states,1));
elseif algorithm_params.true_features,
    F = true_features;
else
    F = eye(states);
end;

% Count features.
features = size(F,2);

% Compute feature expectations.
muE = zeros(features,1);
ex_s = zeros(N,T);
ex_a = zeros(N,T);
mu_sa = zeros(states,actions);
for i=1:N,
    for t=1:T,
        ex_s(i,t) = example_samples{i,t}(1);
        ex_a(i,t) = example_samples{i,t}(2);
        mu_sa(ex_s(i,t),ex_a(i,t)) = mu_sa(ex_s(i,t),ex_a(i,t)) + 1;
        state_vec = zeros(states,1);
        state_vec(ex_s(i,t)) = 1;
        muE = muE + F'*state_vec;
    end;
end;

% Generate initial state distribution for infinite horizon.
initD = sum(sparse(ex_s(:),1:N*T,ones(N*T,1),states,N*T)*ones(N*T,1),2);
for i=1:N,
    for t=1:T,
        s = ex_s(i,t);
        a = ex_a(i,t);
        for k=1:transitions,
            sp = mdp_data.sa_s(s,a,k);
            initD(sp) = initD(sp) - mdp_data.discount*mdp_data.sa_p(s,a,k);
        end;
    end;
end;

fun = @(r)maxentdiscounted(r,F,muE,mu_sa,mdp_data,initD,algorithm_params.laplace_prior);

% Set up optimization options.
options = struct();
options.Display = 'iter';
options.LS_init = 2;
options.LS = 2;
options.Method = 'lbfgs';
if verbosity == 0,
    options.display = 'none';
end;

tic;

% Initialize reward.
r = rand(features,1);

% Run unconstrainted non-linear optimization.
[r,~] = minFunc(fun,r,options);

% Print timing.
time = toc;
if verbosity ~= 0,
    fprintf(1,'Optimization completed in %f seconds.\n',time);
end;

% Convert to full tabulated reward.
wts = r;
r = F*r;

% Return corresponding reward function.
r = repmat(r,1,actions);
soln = mdp_solve(mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'r_itr',{{r}},'model_itr',{{wts}},...
    'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',time);

% Clean up.
clear global prev_v;
clear global prev_d;
