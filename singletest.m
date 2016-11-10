% Convenience script for running a single test.
addpaths;
test_result = runtest('mmp',struct(),'linearmdp',...
    'objectworld',struct('n',32,'determinism',0.7,'seed',1,'continuous',0),...
    struct('training_sample_lengths',8,'training_samples',16,'verbosity',2));
 
% Visualize solution.
printresult(test_result);
visualize(test_result);
