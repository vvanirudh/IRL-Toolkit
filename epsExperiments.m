% Convenience script for running a single test.
clear; clc; close all;
addpaths;
global l1
global lambda
global epsilon
determinism = 0.7;
sample_lengths = 32;
runs_per_test = 5;

% epsilon experiments
numExamples = 512;
num_examples_vect = [];
epsilon_vect = [0.01, 0.05, 0.1, 0.2, 0.5, 0.7, 1.0];
mispred_mat_1 = zeros(length(epsilon_vect), runs_per_test);
sparsity_mat_1 = zeros(length(epsilon_vect), runs_per_test);

lambda = 1;
l1 = 3;
for i=1:length(epsilon_vect)
    epsilon = epsilon_vect(i)
    for j=1:runs_per_test        
        j
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     j,'continuous',0), ...
                              struct('training_sample_lengths', sample_lengths, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
    
        mispred_mat_1(i, j) = test_result(1).metric_scores{1, 1}(1);
        sparsity_mat_1(i, j) = test_result(1).sparsity;
    end
end

save('epsExp2.mat', 'epsilon_vect', 'mispred_mat_1', 'lambda', 'sparsity_mat_1', 'runs_per_test');
    
    
    
