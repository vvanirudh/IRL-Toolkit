% Convenience script for running a single test.
% addpaths;
close all; clear; clc;
test_result = runtest('mmp',struct(),'linearmdp',...
    'highway',struct('n',32,'determinism',0.7,'seed', 1, 'continuous',0, 'policy_type','lawful'),...
    struct('training_sample_lengths', 64, 'training_samples', 512, 'verbosity',2));
 
% Visualize solution.
printresult(test_result);
visualize(test_result);
