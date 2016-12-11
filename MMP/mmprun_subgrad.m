% MMP algorithm implementation.
function irl_result = mmprun_subgrad(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_features,verbosity)

% algorithm_params - parameters of the MMP algorithm:
%       seed (0) - initialization for random seed
%       all_features (0) - use all features as a basis
%       true_features (0) - use true features as a basis
% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       time - total running time

% optim params
n_iter = 400;
lambda = 1;
alpha = 0.95;

% Fill in default parameters.
algorithm_params = mmpdefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);
tic;

% Initialize variables.
[states,actions,transitions] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% set test params
test_params.training_samples = N;
test_params.training_sample_lengths = T;

% Build feature membership matrix.
if algorithm_params.all_features,
    F = feature_data.splittable;
    F = horzcat(F,ones(states,1));
elseif algorithm_params.true_features,
    F = true_features;
else
    F = eye(states);
end;

% Rebuild feature membership matrix to include actions.
Fold = F;
F = [];
for s=1:states,
    F = [F;repmat(Fold(s,:),actions,1)];
end;

% Count features.
features = size(F,2);
F = F';

% Construct state expectations.
[muE, ex_s, ex_a] = calc_mu(N, T, states, actions, example_samples, mdp_data);
Fmu = F*muE;

% Construct loss vector.
% Set l(s,a) = 1 if (s,a) violates example, 0 otherwise.
L = zeros(states*actions,1);
Lcnt = zeros(states*actions,1);
for i=1:N,
    for t=1:T,
        for a=1:actions,
            idx = (ex_s(i,t)-1)*actions+a;
            if a ~= ex_a(i,t),
                L(idx) = (L(idx)*Lcnt(idx)+1)/(Lcnt(idx)+1);
            else
                L(idx) = (L(idx)*Lcnt(idx)+0)/(Lcnt(idx)+1);
            end;
            Lcnt(idx) = Lcnt(idx)+1;
        end;
    end;
end;

% Construct indexing sets.
sN = zeros(states*actions,1);
eN = zeros(states*actions,transitions);
eP = zeros(states*actions,transitions);
for s=1:states,
    for a=1:actions,
        row = (s-1)*actions+a;
        sN(row,1) = s;
        eN(row,:) = mdp_data.sa_s(s,a,:);
        eP(row,:) = mdp_data.sa_p(s,a,:);
    end;
end;

% opt loop
w = zeros(features, 1);
%t = 10;
a = 1;
b = 100;
t = a / b;
cost_vals = [];
cost_subgrad(w, lambda, F, Fmu, muE, L)
for i = 1:n_iter
    % calc r
    r = reshape(F'*w + L, actions, states)';
    
    % get subgradient
    [subgrad, mu_hat] = calc_subgrad(N, T, w, lambda, F, Fmu, L, mdp_data, mdp_model, ...
    test_params, r, states, actions);
    cost = cost_subgrad(w, lambda, F, Fmu, mu_hat, L)
    % update w
    w_new = w - t*subgrad;
%     r_new = reshape(F'*w_new + L, actions, states)';
%     [~, mu_hat_new] = calc_subgrad(N, T, w_new, lambda, F, Fmu, L, mdp_data, mdp_model, ...
%     test_params, r_new, states, actions);
    %cost = cost_subgrad(w_new, lambda, F, Fmu, muE, L)
    
    %if cost_subgrad(w, lambda, F, Fmu, mu_hat, L) > cost
    %    w = w_new;        
    %    cost_vals = [cost_vals; cost];
    %end
    w = w_new;
    t = a / (b + i)
    i
end

% Compute reward.
r = reshape(F'*w, actions, states)';

%{
% Rescale reward.
REWARD_NORM = 50;
r = r-mean(mean(r));
r = r*(REWARD_NORM/sqrt((mean(mean(r.^2)))));
%}

% Compute policies.
soln = mdp_solve(mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;
r_itr = cell(1,1);
tree_r_itr = cell(1,1);
p_itr = cell(1,1);
tree_p_itr = cell(1,1);
wts_itr = cell(1,1);
r_itr{1} = r;
tree_r_itr{1} = r;
p_itr{1} = soln.p;
tree_p_itr{1} = p_itr{1};
wts_itr{1} = w;
time = toc;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'r_itr',{r_itr},'model_itr',{wts_itr},...
    'model_r_itr',{tree_r_itr},'p_itr',{p_itr},'model_p_itr',{tree_p_itr},...
    'time',time);
