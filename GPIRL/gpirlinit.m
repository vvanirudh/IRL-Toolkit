% Initialize the GP structure for GPIRL based on feature data and algorithm
% parameters.
function gp = gpirlinit(algorithm_params,feature_data)

% Create GP.
gp = struct();

% Initialize X.
gp.s_u = 1:size(feature_data.splittable,1);
gp.X = feature_data.splittable;
gp.X_u = feature_data.splittable;

% Copy transform and prior information from parameters.
gp.ard_xform = algorithm_params.ard_xform;
gp.noise_xform = algorithm_params.noise_xform;
gp.rbf_xform = algorithm_params.rbf_xform;
gp.ard_prior = algorithm_params.ard_prior;
gp.noise_prior = algorithm_params.noise_prior;
gp.rbf_prior = algorithm_params.rbf_prior;
gp.ard_prior_wt = algorithm_params.ard_prior_wt;
gp.noise_prior_wt = algorithm_params.noise_prior_wt;
gp.rbf_prior_wt = algorithm_params.rbf_prior_wt;

% Initialize hyperparameters.
gp.noise_var = gpirlhpxform(algorithm_params.noise_init,[],algorithm_params.noise_xform,3);
gp.rbf_var = gpirlhpxform(algorithm_params.rbf_init,[],algorithm_params.ard_xform,3);
gp.inv_widths = gpirlhpxform(algorithm_params.ard_init*ones(1,size(feature_data.splittable,2)),...
    [],algorithm_params.ard_xform,3);

% Specify which values to optimize and how to optimize them.
gp.learn_noise = algorithm_params.learn_noise;
gp.learn_rbf = algorithm_params.learn_rbf;
gp.warp_x = algorithm_params.warp_x;
gp.gamma_shape = algorithm_params.gamma_shape;

% Initialize warp parameters.
if gp.warp_x,
    gp.warp_l = gpirlhpxform(algorithm_params.warp_l_init*ones(1,size(feature_data.splittable,2)),...
        [],algorithm_params.warp_l_xform,3);
    gp.warp_l_prior = algorithm_params.warp_l_prior;
    gp.warp_l_prior_wt = algorithm_params.warp_l_prior_wt;
    gp.warp_l_xform = algorithm_params.warp_l_xform;
    gp.warp_c = gpirlhpxform(algorithm_params.warp_c_init*ones(1,size(feature_data.splittable,2)),...
        [],algorithm_params.warp_c_xform,3);
    gp.warp_c_prior = algorithm_params.warp_c_prior;
    gp.warp_c_prior_wt = algorithm_params.warp_c_prior_wt;
    gp.warp_c_xform = algorithm_params.warp_c_xform;
    gp.warp_s = gpirlhpxform(algorithm_params.warp_s_init*ones(1,size(feature_data.splittable,2)),...
        [],algorithm_params.warp_s_xform,3);
    gp.warp_s_prior = algorithm_params.warp_s_prior;
    gp.warp_s_prior_wt = algorithm_params.warp_s_prior_wt;
    gp.warp_s_xform = algorithm_params.warp_s_xform;
end;
