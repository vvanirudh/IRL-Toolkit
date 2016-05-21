% Run IRL test with specified algorithm and example.
function test_result = runtest(algorithm,algorithm_params,...
    mdp_model,mdp,mdp_params,test_params)

% test_result - structure that contains results of the test:
%   see evaluateirl.m
% algorithm - string specifying the IRL algorithm to use; one of:
%   firl - NIPS 2010 FIRL algorithm
%   bfirl - Bayesian FIRL algorithm
% algorithm_params - parameters of the specified algorithm:
%   FIRL:
%       seed (0) - initialization for random seed
%       iterations (10) - number of FIRL iterations to take
%       depth_step (1) - increase in depth per iteration
%       init_depth (0) - initial depth
%	BFIRL:
%       seed (0) - initialization for random seed
% mdp_model - string specifying MDP model to use for examples:
%   standardmdp - standard MDP model
% mdp - string specifying example to test on:
%   gridworld
% mdp_params - string specifying parameters for example:
%   Gridworld:
%       seed (0) - initialization for random seed
%       n (32) - number of cells along each axis
%       b (4) - size of macro cells
%       determinism (1.0) - probability of correct transition
%       discount (0.9) - temporal discount factor to use
% test_params - general parameters for the test:
%   test_models - models to test on
%   test_metrics - metrics to use during testing
%   training_samples (32) - number of example trajectories to query
%   training_sample_lengths (100) - length of each sample trajectory
%   true_features ([]) - alternative set of true features

% Make sure relevant paths are added.
addpaths;

% Set default test parameters.
test_params = setdefaulttestparams(test_params);

% Construct MDP and features.
[mdp_data,r,feature_data,true_feature_map] = feval(strcat(mdp,'build'),mdp_params);
if ~isempty(test_params.true_features),
    true_feature_map = test_params.true_features;
end;

% Solve example.
mdp_solution = feval(strcat(mdp_model,'solve'),mdp_data,r);

% Sample example trajectories.
if isempty(test_params.true_examples),
    example_samples = sampleexamples(mdp_model,mdp_data,mdp_solution,test_params);
else
    example_samples = test_params.true_examples;
end;

% Run IRL algorithm.
irl_result = feval(strcat(algorithm,'run'),algorithm_params,mdp_data,mdp_model,...
    feature_data,example_samples,true_feature_map,test_params.verbosity);

% Evaluate result.
test_result = evaluateirl(irl_result,r,example_samples,mdp_data,mdp_params,...
    mdp_solution,mdp,mdp_model,test_params.test_models,...
    test_params.test_metrics,feature_data,true_feature_map);
test_result.algorithm = algorithm;
