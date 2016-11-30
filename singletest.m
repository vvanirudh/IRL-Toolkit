% Convenience script for running a single test.
addpaths;
global l1;
numExamples = 2;
determinism = 1.0;
for i=1:9
    fprintf('\n\n -------------- L2 - %d examples ----------------\n', ...
            numExamples);
    l1 = false;
    percentmisprediction = 0;
    featureexpdistance = 0;
    for j=1:10        
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     rand(),'continuous',0), ...
                              struct('training_sample_lengths', 8, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
        %printresult(test_result);
        percentmisprediction = percentmisprediction + test_result(1).metric_scores{1, 1}(1);
        featureexpdistance = featureexpdistance + ...
            test_result(1).metric_scores{1, 3};
    end
    percentmisprediction = percentmisprediction/10.0;
    featureexpdistance = featureexpdistance/10.0;
    
    fprintf('%f, %f\n', percentmisprediction, featureexpdistance);
    
    fprintf('\n\n -------------- L1 - %d examples ----------------\n', ...
            numExamples);
    l1 = true;
    percentmisprediction = 0;
    featureexpdistance = 0;
    for j=1:10
        test_result = runtest('mmp',struct(),'linearmdp','objectworld', ...
                              struct('n',32,'determinism', determinism,'seed', ...
                                     rand(),'continuous',0), ...
                              struct('training_sample_lengths', 8, ...
                                     'training_samples', numExamples,'verbosity', ...
                                     2));
        percentmisprediction = percentmisprediction + test_result(1).metric_scores{1, 1}(1);
        featureexpdistance = featureexpdistance + ...
            test_result(1).metric_scores{1, 3};
    end
    percentmisprediction = percentmisprediction/10.0;
    featureexpdistance = featureexpdistance/10.0;
    
    fprintf('%f, %f\n', percentmisprediction, featureexpdistance);
    
    numExamples = numExamples*2;
    
end
    
    
    
 
% Visualize solution.
%printresult(test_result);
%visualize(test_result);
