% Set default general parameters for the test.
function test_params = humantrialdefaultparams(test_params)

% Create default parameters.
default_params = struct(...
    'training_samples',1,...
    'training_sample_lengths',16,...
    'previous_trial',[]);

% Set parameters.
test_params = filldefaultparams(test_params,default_params);
