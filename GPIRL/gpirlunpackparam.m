% Place parameters from parameter vector into GP.
function [gp,r] = gpirlunpackparam(gp,x)

% Count the last index read.
endi = length(x);

% Read RBF variance hyperparameter if we are learning it.
if gp.learn_rbf,
    gp.rbf_var = x(endi);
    endi = endi-1;
end;

% Read noise hyperparameter if we are learning it.
if gp.learn_noise,
    gp.noise_var = x(endi);
    endi = endi-1;
end;

% Read warping parameters.
if gp.warp_x,
    gp.warp_s = x(endi-length(gp.warp_s)+1:endi)';
    endi = endi-length(gp.warp_s);
    gp.warp_c = x(endi-length(gp.warp_c)+1:endi)';
    endi = endi-length(gp.warp_c);
    gp.warp_l = x(endi-length(gp.warp_l)+1:endi)';
    endi = endi-length(gp.warp_l);
end;

% Read ARD kernel parameters.
gp.inv_widths = x(endi-length(gp.inv_widths)+1:endi)';
endi = endi-length(gp.inv_widths);

% Read reward parameters.
r = x(1:endi);
