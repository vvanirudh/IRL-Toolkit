% Ratliff's MMPBoost algorithm, using decision trees to construct features.
function irl_result = mmpboostrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_features,verbosity)

% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       time - total running time

% Fill in default parameters.
algorithm_params = mmpboostdefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);
tic;

% Initialize variables.
[states,actions,transitions] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% Build initial feature membership matrix.
if isempty(algorithm_params.feature_indices),
    feature_indices = 1:size(feature_data.splittable,2);
else
    feature_indices = algorithm_params.feature_indices;
end;
F = feature_data.splittable(:,feature_indices);
F = horzcat(F,ones(states,1));
features = size(F,2);

% Construct state expectations.
muE = zeros(states*actions,1);
ex_s = zeros(N,T);
ex_a = zeros(N,T);
for i=1:N,
    for t=1:T,
        ex_s(i,t) = example_samples{i,t}(1);
        ex_a(i,t) = example_samples{i,t}(2);
        idx = (ex_s(i,t)-1)*actions+ex_a(i,t);
        muE(idx) = muE(idx) + mdp_data.discount^(t-1);
    end;
end;
muE = muE/N;

% Construct loss vector.
% Set l(s,a) = 1 if (s,a) violates example, 0 otherwise.
Eo = zeros(states,1);
L = zeros(states*actions,1);
Lcnt = zeros(states*actions,1);
for i=1:N,
    for t=1:T,
        Eo(ex_s(i,t)) = ex_a(i,t);
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

% Initialize variables.
r_itr = cell(algorithm_params.iterations,1);
model_r_itr = cell(algorithm_params.iterations,1);
p_itr = cell(algorithm_params.iterations,1);
model_p_itr = cell(algorithm_params.iterations,1);
model_itr = cell(algorithm_params.iterations,1);
model_itr{1} = struct('initial_indices',feature_indices,'added_trees',{{}});

% MMP boost iterations.
for itr=1:algorithm_params.iterations,
    % Compute feature expectation.
    Fk = kron(F,ones(actions,1));
    Fmu = Fk'*muE;

    % Run optimization.
    cvx_begin
        if verbosity ~= 0,
            cvx_quiet(false);
        else
            cvx_quiet(true);
        end;
        variable w(features);
        variable V(states);
        variable S(1);
        minimize(sum_square(w)*0.5+S);
        subject to
            Fmu'*w + S >= (1/states)*sum(V);
            V(sN) >= Fk*w + L + mdp_data.discount*sum(V(eN).*eP,2);
    cvx_end
    model_itr{itr}.wts = w;
    
    % Test for termination.
    if itr==algorithm_params.iterations,
        break;
    end;
    
    % Build loss-augmented reward.
    r = reshape(Fk*w + L,actions,states)';
    
    % Compute optimal policy.
    soln = standardmdpsolve(mdp_data,r);
    p = soln.p;
    r_itr{itr} = r;
    model_r_itr{itr} = r;
    p_itr{itr} = soln.p;
    model_p_itr{itr} = soln.p;
    
    % Build test trajectories.
    Ex = zeros(states,1);
    for i = 1:N,
        s = ex_s(i,1);
        Ex(s) = p(s);
        for t = 2:T,
            s = standardmdpstep(mdp_data,[],s,p(s));
            Ex(s) = p(s);
        end;
    end;
    
    % Build training set.
    set = zeros(1,2);
    row = 1;
    right = 0;
    wrong = 0;
    for s=1:states,
        if Ex(s) ~= 0 && Eo(s) == 0,
            set(row,1) = s;
            set(row,2) = 1;
            right = right+1;
            row = row+1;
        elseif Eo(s) ~= 0 && Ex(s) == 0,
            set(row,1) = s;
            set(row,2) = -1;
            wrong = wrong+1;
            row = row+1;
        end;
    end;
    if verbosity ~= 0,
        fprintf(1,'Got %i right and %i wrong.\n',right,wrong);
    end;
    
    % Train new feature.
    tree = mmpboosttrainfeature(set,0,algorithm_params.depth,0,F);
    
    % Add column to feature matrix.
    newCol = zeros(states,1);
    for s=1:states,
        newCol(s,1) = mmpboostevaltree(tree,s,F);
    end;
    F = horzcat(F,newCol);
    features = size(F,2);
    
    % Build new model.
    model_itr{itr+1} = model_itr{itr};
    model_itr{itr+1}.added_trees = [model_itr{itr+1}.added_trees tree];
end;

% Compute reward and policy.
r = reshape(Fk*w,actions,states)';
soln = mdp_solve(mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;
r_itr{algorithm_params.iterations} = r;
p_itr{algorithm_params.iterations} = p;
model_r_itr{algorithm_params.iterations} = r;
model_p_itr{algorithm_params.iterations} = p;
time = toc;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'r_itr',{r_itr},'model_itr',{model_itr},...
    'model_r_itr',{model_r_itr},'p_itr',{p_itr},'model_p_itr',{model_p_itr},...
    'time',time);
