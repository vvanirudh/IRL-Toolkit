% Fill in default parameters for the MMP algorithm.
function algorithm_params = mmpdefaultparams(algorithm_params)

% Create default parameters.
default_params = struct(...
    'seed',0,...
    'all_features',1,...
    'true_features',0);

% Set parameters.
algorithm_params = filldefaultparams(algorithm_params,default_params);
