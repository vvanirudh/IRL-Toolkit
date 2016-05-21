% Abbeel & Ng algorithm implementation (projection version).
function irl_result = anrun(algorithm_params,mdp_data,mdp_model,...
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

% Fill in default parameters.
algorithm_params = andefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);
tic;

% Initialize variables.
[states,actions,transitions] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% Build feature membership matrix.
if algorithm_params.all_features,
    F = feature_data.splittable;
    % Note that we add a row of 1s to the feature matrix to ensure that we
    % can control the reward at every state.
    F = horzcat(F,ones(states,1));
elseif algorithm_params.true_features,
    F = true_features;
else
    F = eye(states);
end;

% Count features.
features = size(F,2);
F = F';

% Construct state expectations.
muE = zeros(states,1);
ex_s = zeros(N,T);
ex_a = zeros(N,T);
for i=1:N,
    for t=1:T,
        ex_s(i,t) = example_samples{i,t}(1);
        ex_a(i,t) = example_samples{i,t}(2);
        muE(ex_s(i,t)) = muE(ex_s(i,t)) + mdp_data.discount^(t-1);
    end;
end;
muE = muE/N;
Fmu = F*muE;

% Generate random policy.
w = rand(features,1);
r = repmat(F'*w,1,actions);
soln = standardmdpsolve(mdp_data,r);
weights = {w};
solutions = {soln};
mus = {};
mu_bars = {};
itr = 1;

% Initialize t.
t = 100.0;
told = 0.0;

while 1,
    told = t;
    % Compute feature expectations under the last policy.
    om = standardmdpfrequency(mdp_data,solutions{itr});
    mu = F*om;
    
    mus{itr} = mu;
    if itr == 1,
        mu_bars{itr} = mu;
    end;
    
    % Increment iteration count.
    itr = itr + 1;
    
    % Compute t and w using projection.
    if itr == 2,
        % use existing mu.
        mu_bar = mu_bars{itr-1};
        w = Fmu - mu_bar;
        t = norm(Fmu - mu_bar);
    else
        mu_bar_prev = mu_bars{itr-2};
        num = (mu-mu_bar_prev)'*(Fmu-mu_bar_prev);
        denom = (mu-mu_bar_prev)'*(mu-mu_bar_prev);
        ratio = num/denom;
        mu_bar = mu_bar_prev + ratio*(mu-mu_bar);
        
        w = Fmu - mu_bar;
        t = norm(Fmu - mu_bar);
        mu_bars{itr-1} = mu_bar;
    end;
    
    % Recompute optimal policy using new weights.
    r = repmat(F'*w,1,actions);
    soln = standardmdpsolve(mdp_data,r);
    weights{itr} = w;
    solutions{itr} = soln;
    
    % Check convergence.
    if (abs(t-told) <= 0.0001),
        break;
    end;
    
    % Print t.
    if verbosity ~= 0,
        fprintf(1,'Completed IRL iteration, t=%f\n',t);
    end;
end;

% Compute mu for last policy.
om = standardmdpfrequency(mdp_data,solutions{itr});
mu = F*om;
mus{itr} = mu;

% Construct matrix.
mu_mat = zeros(features,itr);
for i=1:itr,
    mu_mat(:,i) = mus{i};
end;

% Solve optimization to determine lambda weights.
cvx_begin
    if verbosity ~= 0,
        cvx_quiet(false);
    else
        cvx_quiet(true);
    end;
    variable mu(features);
    variable lambda(itr);
    minimize(sum_square(mu-Fmu));
    subject to
        mu == mu_mat*lambda;
        lambda >= zeros(itr,1);
        lambda'*ones(itr,1) == 1;
cvx_end

% In Abbeel & Ng's algorithm, we should use the weights lambda to construct
% a stochastic policy. However, here we are evaluating IRL algorithms, so
% we must return a single reward. To this end, we'll simply pick the reward
% with the largest weight lambda.
[~,idx] = max(lambda);
w = weights{idx};

% Compute reward.
r = repmat(F'*w,1,actions);

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
