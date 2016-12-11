% Convenience script for running a single test.
addpaths;
global l1
global lambda
global epsilon
determinism = 0.7;
sample_lengths = 32;
runs_per_test = 5;

% lambda experiments
numExamples = 512;
num_examples_vect = [];
lambda_vect = [0.05 0.1 0.5 1.0 1.5 2.0];
mispred_mat_1 = zeros(length(lambda_vect), runs_per_test);
sparsity_mat_1 = zeros(length(lambda_vect), runs_per_test);
mispred_mat_2 = zeros(length(lambda_vect), runs_per_test);
sparsity_mat_2 = zeros(length(lambda_vect), runs_per_test);
mispred_mat_3 = zeros(length(lambda_vect), runs_per_test);
sparsity_mat_3 = zeros(length(lambda_vect), runs_per_test);
mispred_mat_4 = zeros(length(lambda_vect), runs_per_test);
sparsity_mat_4 = zeros(length(lambda_vect), runs_per_test);

epsilon = 0.1;
for i=1:length(lambda_vect)
    lambda = lambda_vect(i);
    
    l1 = 1;
    for j=1:runs_per_test        
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     sum(100*clock),'continuous',0), ...
                              struct('training_sample_lengths', sample_lengths, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
    
        mispred_mat_1(i, j) = test_result(1).metric_scores{1, 1}(1);
        sparsity_mat_1(i, j) = test_result(1).sparsity;
    end

    l1 = 2;
    for j=1:runs_per_test        
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     sum(100*clock),'continuous',0), ...
                              struct('training_sample_lengths', sample_lengths, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
    
        mispred_mat_2(i, j) = test_result(1).metric_scores{1, 1}(1);
        sparsity_mat_2(i, j) = test_result(1).sparsity;
    end
    
    
    l1 = 3;
    for j=1:runs_per_test        
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     sum(100*clock),'continuous',0), ...
                              struct('training_sample_lengths', sample_lengths, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
    
        mispred_mat_3(i, j) = test_result(1).metric_scores{1, 1}(1);
        sparsity_mat_3(i, j) = test_result(1).sparsity;
    end
    
    l1 = 4;
    for j=1:runs_per_test        
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     sum(100*clock),'continuous',0), ...
                              struct('training_sample_lengths', sample_lengths, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
    
        mispred_mat_4(i, j) = test_result(1).metric_scores{1, 1}(1);
        sparsity_mat_4(i, j) = test_result(1).sparsity;
    end
end
    

save('lambdaExp.mat', 'lambda_vect', 'mispred_mat_1', 'sparsity_mat_1', ...
     'mispred_mat_2', 'sparsity_mat_2',  'mispred_mat_3', 'sparsity_mat_3',...
      'mispred_mat_4', 'sparsity_mat_4', 'epsilon', 'runs_per_test');
    
