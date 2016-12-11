% Convenience script for running a single test.
close all; clc
global l1
l1 = true;
addpaths;
test_result = runtest('mmp',struct(),'linearmdp',...
    'objectworld',struct('n',32,'determinism',0.7,'seed',2,'continuous',0),...
    struct('training_sample_lengths',32,'training_samples',256,'verbosity',2));
 
% Visualize solution.
printresult(test_result);
visualize(test_result);