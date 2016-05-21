% Add paths.
addpaths;

% A simple unit test for runtestseries.m
[algorithms,algorithm_params,names,colors,order] = getalgorithms(1,0,1,1,1,1,0);
disp(names);

% Set up constants.
[test_models,test_metrics,test_model_names,test_metric_names] = getmetrics();
test_params = struct('training_sample_lengths',8,'training_samples',32,...
    'test_models',{test_models},'test_metrics',{test_metrics},'verbosity',0);
n = 32;
mdp_model = 'linearmdp';
restarts = 8;
transfers = 4;
world = 'objectworld';

% Prepare MDP parameters.
mdp_cat_name = 'Colors';
mdp_param_names = {'2','4','6','8','10','12'};
mdp_params = {struct('n',n,'determinism',0.7,'seed',0)};
mdp_params = repmat(mdp_params,1,length(mdp_param_names));

% Prepare test parameters.
test_params = {setdefaulttestparams(test_params)};
test_params = repmat(test_params,1,length(mdp_param_names));
mdp_params{1}.c1 = 2;
mdp_params{1}.c2 = 2;
mdp_params{2}.c1 = 4;
mdp_params{2}.c2 = 4;
mdp_params{3}.c1 = 6;
mdp_params{3}.c2 = 6;
mdp_params{4}.c1 = 8;
mdp_params{4}.c2 = 8;
mdp_params{5}.c1 = 10;
mdp_params{5}.c2 = 10;
mdp_params{6}.c1 = 12;
mdp_params{6}.c2 = 12;

% Run tests.
series_result = runtestseries(algorithms,algorithm_params,...
    mdp_model,test_params,world,mdp_params,restarts);

% Run transfer tests.
transfer_result = runtransferseries(algorithms,series_result,...
    mdp_model,test_params,world,mdp_params,restarts,transfers);

% Print.
printstats(1,test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,restarts,...
    series_result,transfer_result);

% Save.
saveresults('Objectworld_Colors',test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,colors,order,...
    restarts,series_result,transfer_result);
