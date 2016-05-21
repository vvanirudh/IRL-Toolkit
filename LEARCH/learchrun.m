% Ratliff's LEARCH algorithm, with optional nonlinear steps.
function irl_result = learchrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_features,verbosity)

% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       time - total running time

% The log-linear version of LEARCH follows the derivation from Ratliff's
% article. The nonlinear version uses either logistic regression or
% decision trees. In both cases, the nonlinear step is invoked every 10th
% iteration of exponential coordinate ascent.

% Fill in default parameters.
algorithm_params = learchdefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);
tic;

% Initialize variables.
[states,actions,~] = size(mdp_data.sa_p);
[N,T] = size(example_samples);
mdp_solve = str2func(strcat(mdp_model,'solve'));

% Build feature membership matrix.
if algorithm_params.all_features,
    F = feature_data.splittable';
elseif algorithm_params.true_features,
    F = true_features';
else
    F = eye(states);
end;

% Construct example sets.
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

% Construct loss vector.
% Set l(s,a) = 1 if (s,a) violates example, 0 otherwise.
Eo = zeros(states,1);
L = zeros(states,actions);
Lcnt = zeros(states,actions);
for i=1:N,
    for t=1:T,
        Eo(ex_s(i,t)) = ex_a(i,t);
        s = ex_s(i,t);
        for a=1:actions,
            if a ~= ex_a(i,t),
                L(s,a) = (L(s,a)*Lcnt(s,a)+1)/(Lcnt(s,a)+1);
            else
                L(s,a) = (L(s,a)*Lcnt(s,a)+0)/(Lcnt(s,a)+1);
            end;
            Lcnt(s,a) = Lcnt(s,a)+1;
        end;
    end;
end;

% Initialize variables.
s = zeros(states,1);
rate = 0.1; % Learning rate.
m = 10; % How fast step size shrinks.
model = struct();
model.linweights = zeros(size(F,1),1);
if ~isempty(strfind(algorithm_params.function,'linear')),
    train_linear = 1;
else
    train_linear = 0;
end;
if ~isempty(strfind(algorithm_params.function,'dtree')),
    model.trees = {};
end;
if ~isempty(strfind(algorithm_params.function,'logistic')),
    model.logistics = {};
end;

% LEARCH iterations.
for itr=1:algorithm_params.iterations,
    % Build loss-augmented reward.
    r = repmat(-exp(s),1,actions);
    r = r + L;
    
    % Compute optimal policy.
    soln = standardmdpsolve(mdp_data,r);
    muS = standardmdpfrequency(mdp_data,soln);
    
    % Choose alpha.
    alpha = rate/(itr+m);
    if verbosity ~= 0,
        fprintf(1,'Itr %i\n',itr);
    end;
    
    % Train new feature.
    if train_linear && ((~isfield(model,'trees') && ~isfield(model,'logistics')) || mod(itr,10) ~= 0),
        % Compute parameteric gradient.
        g = F*(muE-muS) + 0.1*sign(model.linweights);
        C = F*diag(muE+muS)*F';
        warning off MATLAB:lscov:RankDefDesignMat;
        Cinvg = lscov(C,g);
        warning on MATLAB:lscov:RankDefDesignMat;
        model.linweights = model.linweights - alpha*Cinvg;
        s = s - alpha*F'*Cinvg;
    elseif isfield(model,'logistics'),
        % Compute logistic split.
        g = muS-muE;
        y = g > 0; % Make it binary.
        % Try to fit a logistic according to each feature.
        warning off stats:glmfit:IterationLimit;
        logistic = learchtrainlogistic(y,F');
        newCol = learchevallogistic(logistic,F');
        warning on stats:glmfit:IterationLimit;
        % Add logistic.
        model.logistics = [model.logistics logistic];
        F = vertcat(F,newCol');
        if train_linear,
            alpha = 0; % Let the linear steps select this weight.
        end;
        model.linweights = vertcat(model.linweights,alpha);
        s = s + alpha*newCol;
    elseif isfield(model,'trees'),
        % Compute gradient.
        g = muS-muE;
        tree = mmpboosttrainfeature(horzcat([1:states]',g),0,algorithm_params.depth,0,F'>0);
        model.trees = [model.trees tree];
        newCol = zeros(states,1);
        mat = F'>0;
        for ss=1:states,
            newCol(ss,1) = mmpboostevaltree(tree,ss,mat);
        end;
        F = vertcat(F,newCol');
        model.linweights = vertcat(model.linweights,alpha);
        s = s + alpha*newCol;
    end;
end;

% Compute reward and policy.
r = repmat(-exp(s-max(s)+log(10)),1,actions);
soln = mdp_solve(mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;
r_itr = cell(1,1);
model_r_itr = cell(1,1);
p_itr = cell(1,1);
model_p_itr = cell(1,1);
model_itr = cell(1,1);
r_itr{1} = r;
model_r_itr{1} = r;
p_itr{1} = soln.p;
model_p_itr{1} = p_itr{1};
model_itr{1} = model;
time = toc;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'r_itr',{r_itr},'model_itr',{model_itr},...
    'model_r_itr',{model_r_itr},'p_itr',{p_itr},'model_p_itr',{model_p_itr},...
    'time',time);
