% MMP algorithm implementation.
function irl_result = mmprun_cp(algorithm_params,mdp_data,mdp_model,...
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

global lambda
global epsilon

% optim params
n_iter = 400;

% mu set
mu_set = [];

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
cost_vals = [];
w = ones(features, 1);
S_xi = 0;
count = 0;
fprintf('EPSILON : %f', epsilon);
while true
    r = reshape(F'*w + L, actions, states)';
    
    % solve MDP
    mdp_solution = feval(strcat(mdp_model,'solve'), mdp_data, r);
    
    % get samples
    examples = sampleexamples(mdp_model, mdp_data, mdp_solution, ...
        test_params);
    
    % get mu
    [mu_hat, ~, ~] = calc_mu(N, T, states, actions, examples, mdp_data);
    
    max_constr_val = 0;
    % iterate over past mu's
    if size(mu_set,1) ~= 0
        max_constr_val = max((F'*w + L)' * mu_set' - Fmu'*w);
        max_constr_val = max_constr_val(1);
    else
        max_constr_val = 0;
    end
    % fprintf('term1 %f\n', (F'*w+L)'*mu_hat - Fmu'*w);
    % fprintf('term2 %f\n', max_constr_val);
    % check if we should add this to the constraint set
    if size(mu_set, 1)==0 || (F'*w+L)'*mu_hat - Fmu'*w > max_constr_val + epsilon
        mu_set = [mu_set; mu_hat'];        
        % set up linprog
        f = [ones(2*features,1)*lambda/2; 1];
        Q = repmat(Fmu, 1, size(mu_set, 1)) - F * mu_set';
        A = -[Q', -Q', ones(size(Q, 2), 1)];
        b = - mu_set * L;
        lb = [zeros(2*features, 1); -Inf];
        
        [x,~,~,output] = linprog(f, A, b, [], [], lb, []);
        alph = x(1:features);
        bet = x(features+1:2*features);
        S_xi = x(end);
        w = alph - bet;
        count = count + output.iterations
        size(mu_set, 1)
    else
        break;
    end
    
    cost = lambda/2 * norm(w,1) + S_xi
    cost_vals = [cost_vals; cost];
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
    'time',time, 'sparsity', length(find(abs(w) > 1e-8)));
