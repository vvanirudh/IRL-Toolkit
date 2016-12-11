% MMP algorithm implementation.
function irl_result = mmprun2(algorithm_params,mdp_data,mdp_model,...
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
algorithm_params = mmpdefaultparams(algorithm_params);

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
muE = zeros(N, states*actions);
ex_s = zeros(N,T);
ex_a = zeros(N,T);
for i=1:N,
    for t=1:T,
        ex_s(i,t) = example_samples{i,t}(1);
        ex_a(i,t) = example_samples{i,t}(2);
        idx = (ex_s(i,t)-1)*actions+ex_a(i,t);
        muE(i, idx) = muE(i, idx) + mdp_data.discount^(t-1);
    end;
end;

Fmu = muE * F';

% Construct loss vector.
% Set l(s,a) = 1 if (s,a) violates example, 0 otherwise.
L = zeros(N, states*actions);
Lcnt = zeros(N, states*actions);
for i=1:N,
    for t=1:T,
        for a=1:actions,
            idx = (ex_s(i,t)-1)*actions+a;
            if a ~= ex_a(i,t),
                L(i, idx) = (L(i, idx)*Lcnt(i, idx)+1)/(Lcnt(i, idx)+1);
            else
                L(i, idx) = (L(i, idx)*Lcnt(i, idx)+0)/(Lcnt(i, idx)+1);
            end;
            Lcnt(i, idx) = Lcnt(i, idx)+1;
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

lambda = 0.5;

% Run optimization.
cvx_begin
    cvx_solver sdpt3
    if verbosity ~= 0,
        cvx_quiet(false);
    else
        cvx_quiet(true);
    end;
    variable w(features);
    variable V(N, states);
    variable S(N);
    
%     minimize(lambda*sum_square(w) + (1/N) * sum(S));
    minimize(lambda*sum(abs(w)) + (1/N) * sum(S));
    subject to
        Fmu * w + S >= (1/states) * sum(V, 2);
        
        for i = 1:N
            reshape(repmat(V(i, :)', 1, 5)', 1, states*actions) >= w'*F + L(i, :) + mdp_data.discount * sum(...
                reshape(V(i, eN), size(eN)) .* eP, 2)';
            i
        end
        S >= 0;
cvx_end

%     keyboard()

% Compute reward.
r = reshape(F'*w,actions,states)';

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
