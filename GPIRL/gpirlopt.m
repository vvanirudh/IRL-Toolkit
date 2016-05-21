% Compute likelihood of GP IRL parameters, as well as likelihood gradient.
function [val,dp] = gpirlopt(x,gp,mu_sa,init_s,mdp_data)

% Set constants.
[~,actions] = size(mu_sa);
samples = length(gp.s_u);

% Unpack parameters.
[gp,u] = gpirlunpackparam(gp,x);

% Compute kernel and kernel matrix derivatives.
if nargout >= 2,
    [Kstar,logDetAndPPrior,alpha,Kinv,dhp,dhpdr] = gpirlkernel(gp,u);
else
    [Kstar,logDetAndPPrior,alpha] = gpirlkernel(gp,u);
end;

% Compute GP likelihood.
gpLogLike = -0.5*u'*alpha - logDetAndPPrior - 0.5*samples*log(2*pi);

% Add hyperparameter priors.
hpLogLike = 0;
hpLogLike = hpLogLike + gpirlhpprior(gp.inv_widths,gp.ard_prior,...
    gp.ard_prior_wt,gp.ard_xform,gp);
hpLogLike = hpLogLike + gpirlhpprior(gp.noise_var,gp.noise_prior,...
    gp.noise_prior_wt,gp.noise_xform,gp);
hpLogLike = hpLogLike + gpirlhpprior(gp.rbf_var,gp.rbf_prior,...
    gp.rbf_prior_wt,gp.rbf_xform,gp);
if gp.warp_x,
    hpLogLike = hpLogLike + gpirlhpprior(gp.warp_l,gp.warp_l_prior,...
        gp.warp_l_prior_wt,gp.warp_l_xform,gp);
    hpLogLike = hpLogLike + gpirlhpprior(gp.warp_c,gp.warp_c_prior,...
        gp.warp_c_prior_wt,gp.warp_c_xform,gp);
    hpLogLike = hpLogLike + gpirlhpprior(gp.warp_s,gp.warp_s_prior,...
        gp.warp_s_prior_wt,gp.warp_s_xform,gp);
end;

% Compute reward under deterministic conditional approximation.
rew = Kstar'*alpha;

% Run value iteration to get policy.
[~,~,policy,logpolicy] = linearvalueiteration(mdp_data,repmat(rew,1,actions));

% Compute value by adding up log example probabilities.
meLogLike = sum(sum(logpolicy.*mu_sa));

% Compute total log likelihood and invert for descent.
val = meLogLike + gpLogLike + hpLogLike;
val = -val;

if nargout >= 2,    
    % Add hyperparameter prior gradients.
    dhp(1:length(gp.inv_widths)) = dhp(1:length(gp.inv_widths)) + ...
        gpirlhppriorgrad(gp.inv_widths,gp.ard_prior,gp.ard_prior_wt,gp.ard_xform,gp);
    idx = length(gp.inv_widths)+1;
    if gp.warp_x,
        dhp(idx:idx-1+length(gp.inv_widths)) = dhp(idx:idx-1+length(gp.inv_widths)) + ...
            gpirlhppriorgrad(gp.warp_l,gp.warp_l_prior,gp.warp_l_prior_wt,gp.warp_l_xform,gp);
        idx = idx+length(gp.inv_widths);
        dhp(idx:idx-1+length(gp.inv_widths)) = dhp(idx:idx-1+length(gp.inv_widths)) + ...
            gpirlhppriorgrad(gp.warp_c,gp.warp_c_prior,gp.warp_c_prior_wt,gp.warp_c_xform,gp);
        idx = idx+length(gp.inv_widths);
        dhp(idx:idx-1+length(gp.inv_widths)) = dhp(idx:idx-1+length(gp.inv_widths)) + ...
            gpirlhppriorgrad(gp.warp_s,gp.warp_s_prior,gp.warp_s_prior_wt,gp.warp_s_xform,gp);
        idx = idx+length(gp.inv_widths);
    end;
    if gp.learn_noise,
        dhp(idx) = dhp(idx) + ...
            gpirlhppriorgrad(gp.noise_var,gp.noise_prior,gp.noise_prior_wt,gp.noise_xform,gp);
        idx = idx+1;
    end;
    if gp.learn_rbf,
        dhp(idx) = dhp(idx) + ...
            gpirlhppriorgrad(gp.rbf_var,gp.rbf_prior,gp.rbf_prior_wt,gp.rbf_xform,gp);
        idx = idx+1;
    end;
    
    % Compute state visitation count D and reward gradient.
    D = linearmdpfrequency(mdp_data,struct('p',policy),init_s);
    drew = sum(mu_sa,2) - D;
    
    % Apply posterior Jacobian.
    dr = Kinv*(Kstar*drew);
    dhp = dhp+dhpdr*drew;
    
    % Add derivative of GP likelihood.
    dudr = eye(samples);
    dr = dr - dudr*alpha;
    
    % Combine and invert for descent.
    dp = vertcat(dr,dhp);
    dp = -dp;

    if any(isnan([dp;val])),
        save dump_file;
        error('WARNING: detected NaN or Inf!\n');
    end;
end;
