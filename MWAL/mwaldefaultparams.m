% Fill in default parameters for the MWAL algorithm.
function algorithm_params = mwaldefaultparams(algorithm_params)

% Create default parameters.
default_params = struct(...
    'seed',0,...
    'all_features',1,...
    'true_features',0);

% Set parameters.
algorithm_params = filldefaultparams(algorithm_params,default_params);
