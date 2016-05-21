% Add paths.
addpaths;

% A simple unit test for runtestseries.m
[algorithms,algorithm_params,names,colors,order] = getalgorithms(1,0,0,1,1,1,1);
disp(names);

% Load up the examples.
INIT_SEED = 0;
NUM_SEEDS = 8;
human_results = cell(NUM_SEEDS,1);
for i=1:NUM_SEEDS,
    load(['Human_Demos/highway_outlaw_demo_seed_' num2str(INIT_SEED+i-1) '_length_64.mat']);
    human_results{i} = human_result.example_samples;
end;

[test_models,test_metrics,test_model_names,test_metric_names] = getmetrics();

% Add highway-specific metrics.
test_metrics = [test_metrics {'speed','police'}];
test_metric_names = [test_metric_names {'Mean Speed','Speeding Probability'}];

test_params = struct('training_sample_lengths',32,'training_samples',2,...
    'true_examples',{human_result.example_samples},...
    'test_models',{test_models},'test_metrics',{test_metrics},'verbosity',0);
mdp_model = 'linearmdp';
restarts = NUM_SEEDS;
transfers = 4;
world = 'highway';

% Prepare MDP parameters.
mdp_cat_name = 'Examples';
mdp_param_names = {'2','4','8','16'};
mdp_params = {struct('length',64,'num_cars',[34 6],'continuous',1,'determinism',0.7,'seed',INIT_SEED)};
mdp_params = repmat(mdp_params,1,length(mdp_param_names));

% Prepare test parameters.
test_params = {setdefaulttestparams(test_params)};
test_params = repmat(test_params,NUM_SEEDS,length(mdp_param_names));
for i=1:NUM_SEEDS,
    test_params{i,1}.training_samples = 2;
    test_params{i,1}.true_examples = human_results{i}(1:2,:);
    test_params{i,2}.training_samples = 4;
    test_params{i,2}.true_examples = human_results{i}(1:4,:);
    test_params{i,3}.training_samples = 8;
    test_params{i,3}.true_examples = human_results{i}(1:8,:);
    test_params{i,4}.training_samples = 16;
    test_params{i,4}.true_examples = human_results{i}(1:16,:);
end;

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
saveresults('Highway_Human_Cont',test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,colors,order,...
    restarts,series_result,transfer_result);
