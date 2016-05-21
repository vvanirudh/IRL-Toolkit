% Place parameters from specified GP into parameter vector.
function x = gpirlpackparam(gp,r)

% First, add the reward parameters.
x = r;

% Next, add ARD kernel parameters.
x = vertcat(x,gp.inv_widths');

% Add additional kernel parameters if we have warping.
if gp.warp_x,
    x = vertcat(x,gp.warp_l');
    x = vertcat(x,gp.warp_c');
    x = vertcat(x,gp.warp_s');
end;

% Add noise hyperparameter if we are learning it.
if gp.learn_noise,
    x = vertcat(x,gp.noise_var);
end;

% Add RBF variance hyperparameter if we are learning it.
if gp.learn_rbf,
    x = vertcat(x,gp.rbf_var);
end;
