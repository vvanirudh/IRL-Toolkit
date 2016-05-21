% GP-based non-linear IRL algorithm.
function irl_result = gpirlrun(algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,~,verbosity)

% algorithm_params - parameters of the GP IRL algorithm.
% mdp_data - definition of the MDP to be solved.
% example_samples - cell array containing examples.
% irl_result - result of IRL algorithm (see bottom of file).

% Fill in default parameters.
algorithm_params = gpirldefaultparams(algorithm_params);

% Set random seed.
rand('seed',algorithm_params.seed);
randn('seed',algorithm_params.seed);

% Get state-action counts and initial state distributions.
[mu_sa,init_s] = gpirlgetstatistics(example_samples,mdp_data);

% Set up optimization options.
options = struct('Display','iter','LS_init',2,'LS',2,'Method','lbfgs',...
    'MaxFunEvals',4000,'MaxIter',2000);
if verbosity < 2,
    options.display = 'none';
end;

% Initialize r.
if ~isempty(algorithm_params.initial_r),
    % Use provided initialization.
    if ~iscell(algorithm_params.initial_r),
        r = {mean(algorithm_params.initial_r,2)};
    else
        r = algorithm_params.initial_r;
        for i=1:length(r),
            r{i} = mean(r{i},2);
        end;
    end;
else
    % Use random initialization.
    r = cell(algorithm_params.initial_rewards,1);
    for i=1:length(r),
        r{i} = rand(mdp_data.states,1);
    end;
end;

% Create GP.
if ~isempty(algorithm_params.initial_gp),
    gp = algorithm_params.initial_gp;
else
    % Create initial GP.
    gp = gpirlinit(algorithm_params,feature_data);
    % Choose inducing points.
    gp = gpirlgetinducingpoints(gp,r,mu_sa,algorithm_params);
end;

% Create anonymous function.
fun = @(x)gpirlopt(x,gp,mu_sa,init_s,mdp_data);

% Remove mean from reward.
% Note: this is here due to a minor oversight when generating the NIPS 11
% results. Since the results in the paper were generated with this line
% present, it has been left in to ensure reproducibility. Removing it does
% not change the results in a significant way, but makes the values deviate
% slightly from those shown in the result tables.
% TODO: remove.
r{1} = r{1}-mean(r{1},1);

% Uncomment the following line to enable derivatives.
%options.DerivativeCheck = 'on';

% Since we will be running multiple iterations, start with high tolerance.
options.TolFun = algorithm_params.restart_tolerance;

% Run unconstrainted non-linear optimizations.
% First run the initial runs with random rewards.
best_nll = Inf;
total_time = 0;
for k=1:length(r),
    tic;
    [x,nll] = minFunc(fun,gpirlpackparam(gp,r{k}(gp.s_u,1)),options);
    time = toc;
    if nll < best_nll,
        best_nll = nll;
        best_x = x;
    end;
    if verbosity ~= 0,
        fprintf(1,'Completed initial run %i of %i in %f s, LL = %f\n',k,length(r),time,-nll);
    end;
    total_time = total_time + time;
end;

% Now run additional restarts to get kernel parameters correct.
if gp.warp_x,
    % Doing random restarts.
    iterations = algorithm_params.warp_x_restarts;
else
    % Restart is deterministic, so no need for more than 2.
    iterations = 1;
end;
for k=1:iterations,
    tic;
    [~,u] = gpirlunpackparam(gp,best_x);
    if gp.warp_x,
        % Randomize centers.
        new_c = gamrnd(gp.gamma_shape,1.0/gp.warp_c_prior_wt,size(gp.warp_c));
        gp.warp_c = gpirlhpxform(new_c,[],gp.warp_c_xform,3);
    end;
    [x,nll] = minFunc(fun,gpirlpackparam(gp,u),options);
    time = toc;
    if verbosity ~= 0,
        fprintf(1,'Completed restart %i in %f s, LL = %f\n',k,time,-nll);
    end;
    if nll < best_nll,
        best_nll = nll;
        best_x = x;
    end;
    total_time = total_time+time;
end;

% Now re-run the best value with normal tolerance.
options.TolX = 1e-9;
options.TolFun = 1e-5;
options.MaxIter = 2000;
tic;
[best_x,best_nll] = minFunc(fun,best_x,options);
time = toc;
if verbosity ~= 0,
    fprintf(1,'Completed finalization run in %f s, LL = %f\n',time,-best_nll);
end;
total_time = total_time+time;
[gp,u] = gpirlunpackparam(gp,best_x);
time = total_time;
nll = best_nll;

if verbosity ~= 0,
    fprintf(1,'Optimization completed in %f seconds with log-likelihood %f.\n',time,-nll);
end;

% Return corresponding reward function.
gp.Y = u;
[Kstar,~,alpha] = gpirlkernel(gp,u);
r = Kstar'*alpha;
r = repmat(r,1,mdp_data.actions);
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Construct returned structure.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{gp}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',time,'score',-nll);
