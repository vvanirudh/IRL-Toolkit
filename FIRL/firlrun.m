% Run the FIRL inverse reinforcement learning algorithm.
function irl_result = firlrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,~,verbosity)

% algorithm_params - parameters of the FIRL algorithm:
%       seed (0) - initialization for random seed
%       iterations (10) - number of FIRL iterations to take
%       depth_step (1) - increase in depth per iteration
%       init_depth (0) - initial depth
% mdp_data - definition of the MDP to be solved
% example_samples - cell array containing examples
% irl_result - result of IRL algorithm, generic and algorithm-specific:
%       r - inferred reward function
%       v - inferred value function.
%       q - corresponding q function.
%       p - corresponding policy.
%       opt_acc_itr - cell array containing optimization accuracy at each iteration
%       r_itr - post-optimization reward table at each iteration
%       p_itr - post-optimization policy at each iteration
%       model_itr - post-fitting tree at each iteration
%       model_r_itr - post-fitting reward at each iteration
%       model_p_itr - final policy at each iteration
%       time - total running time
%       mean_opt_time - average optimization time
%       mean_fit_time - average fitting time

% Fill in default parameters.
algorithm_params = firldefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);

% Initialize variables.
states = mdp_data.states;
actions = mdp_data.actions;
iterations = algorithm_params.iterations-1;
depthstep = algorithm_params.depth_step;
initdepth = algorithm_params.init_depth;

% Construct mapping from states to example actions.
Eo = zeros(states,1);
for i=1:size(example_samples,1),
    for t=1:size(example_samples,2),
        Eo(example_samples{i,t}(1)) = example_samples{i,t}(2);
    end;
end;

% Construct initial tree.
leaves = 1;
tree = struct('type',0,'index',1,'mean',zeros(1,actions));
[ProjToLeaf,LeafToProj,FeatureMatch] = firlprojectionfromtree(...
    tree,leaves,states,actions,feature_data);

% Prepare timing variables.
optTime = zeros(iterations+1,1);
fitTime = zeros(iterations+1,1);
vitTime = zeros(iterations+1,1);
matTime = zeros(iterations+1,1);

% Prepare intermediate output variables.
opt_acc_itr = cell(iterations+1,1);
r_itr = cell(iterations+1,1);
p_itr = cell(iterations+1,1);
model_itr = cell(iterations+1,1);
model_r_itr = cell(iterations+1,1);
model_p_itr = cell(iterations+1,1);

% Run firl.
Rold = [];
itr = 0;
while 1,
    if verbosity ~= 0,
        fprintf(1,'Beginning FIRL iteration %i\n',itr);
    end;
    
    % Run optimization phase.
    tic;
    [R,margin] = firloptimization(Eo,Rold,ProjToLeaf,LeafToProj,...
        FeatureMatch,mdp_data,verbosity);
    Rold = R;
    threshold = margin*0.2*mdp_data.discount;
    optTime(itr+1,1) = toc;
    
    % Generate policy.
    tic;
    V = stdvalueiteration(mdp_data,R);
    [~,P] = stdpolicy(mdp_data,R,V);
    vitTime(itr+1,1) = toc;
    
    % Construct tree.
    tic;
    % Adjust Eo to exclude violated examples.
    % In an exact optimization, there should be no violated examples.
    % However, an approximation might violate some examples.
    Eadjusted = Eo.*(P == Eo);
    totalExamples = length(find(Eadjusted));
    opt_acc_itr{itr+1} = totalExamples/length(find(Eo));
    max_depth = initdepth+itr*depthstep;
    [tree,leaves,~,~] = firlregressiontree(...
        1:states,...        % Start with all states.
        0,...               % Current depth.
        0,...               % First leaf index.
        Eadjusted,...       % Pass in part of policy we want to match.
        R,...               % Pass in reward function.
        V,...               % Pass in value function.
        threshold,...       % Pass in termination threshold.
        max_depth,...       % Pass in maximum depth.
        mdp_data,...        % Pass in MDP data.
        feature_data);      % Pass in feature data.
    fitTime(itr+1,1) = toc;
    
    % Construct projection matrices.
    tic;
    [ProjToLeaf,LeafToProj,FeatureMatch] = firlprojectionfromtree(...
        tree,leaves,states,actions,feature_data);
    matTime(itr+1,1) = toc;
    
    % Record policy at this iteration.
    r_itr{itr+1} = R;
    p_itr{itr+1} = P;
    model_itr{itr+1} = tree;
    
    % Check convergence condition.
    if itr == iterations,
        break;
    end;
    
    % Increment iteration.
    itr = itr + 1;
end;

% Compute final policy.
Rout = firlaveragereward(tree,R,actions);
Vout = stdvalueiteration(mdp_data,Rout);
[Qout,Pout] = stdpolicy(mdp_data,Rout,Vout);

% Compute all intermediate policies.
for i=1:iterations+1,
    model_r_itr{i} = firlaveragereward(model_itr{i},r_itr{i},actions);
    v = stdvalueiteration(mdp_data,model_r_itr{i});
    [~,model_p_itr{i}] = stdpolicy(mdp_data,model_r_itr{i},v);
end;

if verbosity ~= 0,
    % Report timing.
    for itr=1:iterations+1,
        fprintf(1,'Iteration %i optimization: %f\n',itr,optTime(itr,1));
        fprintf(1,'Iteration %i value iteration: %f\n',itr,vitTime(itr,1));
        fprintf(1,'Iteration %i fitting: %f\n',itr,fitTime(itr,1));
        fprintf(1,'Iteration %i objective construction: %f\n',itr,matTime(itr,1));
    end;
end;
total = sum(optTime)+sum(vitTime)+sum(fitTime)+sum(matTime);
if verbosity ~= 0,
    fprintf(1,'Total time: %f\n\n',total);
end;
time = total;
mean_opt_time = mean(optTime);
mean_fit_time = mean(fitTime);

% Build output structure.
irl_result = struct('r',Rout,'v',Vout,'q',Qout,'p',Pout,'opt_acc_itr',{opt_acc_itr},...
    'r_itr',{r_itr},'model_itr',{model_itr},'model_r_itr',{model_r_itr},'p_itr',{p_itr},...
    'model_p_itr',{model_p_itr},'time',time,'mean_opt_time',mean_opt_time,...
    'mean_fit_time',mean_fit_time);
