% Fill in default parameters for the OptV algorithm.
function algorithm_params = optvdefaultparams(algorithm_params)

% Create default parameters.
default_params = struct(...
    'seed',0);

% Set parameters.
algorithm_params = filldefaultparams(algorithm_params,default_params);
