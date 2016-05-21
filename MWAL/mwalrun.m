% MWAL algorithm implementation.
function irl_result = mwalrun(algorithm_params,mdp_data,mdp_model,...
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
algorithm_params = mwaldefaultparams(algorithm_params);

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
Fmu = vertcat(Fmu,-Fmu);

T = 50;

% Compute beta.
beta = 1.0/(1+sqrt(2*log(features*2)/T));

% Build initial W.
W = ones(features*2,1);

% Initialize variables.
weights = {};
solutions = {};
mus = {};

for t=1:T,
    % Build w.
    w = W/sum(W);
    
    % "fold" the weights.
    w = w(1:features)-w(features+1:2*features);
    
    % Compute reward.
    r = repmat(F'*w,1,actions);
    soln = standardmdpsolve(mdp_data,r);
    solutions{t} = soln;
    weights{t} = w;
    
    % Estimate mu.
    om = standardmdpfrequency(mdp_data,solutions{t});
    mu = F*om;
    mu = vertcat(mu,-mu);
    mus{t} = mu;
    
    % Compute next W.
    if t < T,
        % Compute G.
        G = zeros(features*2,1);
        for k=1:features*2,
            G(k) = ((1-mdp_data.discount)*(mu(k)-Fmu(k)) + 2)/4;
        end;
        % Update W.
        for k=1:features*2,
            W(k) = W(k)*exp(log(beta)*G(k));
        end;
    end;
    if verbosity ~= 0,
        fprintf(1,'Completed IRL iteration %i of %i\n',t,T);
    end;
end;

% Find the closest expectation and return it.
bestDiff = Inf;
for i=1:length(mus),
    cmu = mus{i};
    difference = norm(cmu(:) - Fmu(:));
    if difference < bestDiff,
        bestDiff = difference;
        w = weights{i};
    end;
end;

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
