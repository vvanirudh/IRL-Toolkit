% Compute prior likelihood of hyperparameters.
function val = gpirlhpprior(hp,prior,prior_wt,xform,gp)

% Transform.
hp = gpirlhpxform(hp,[],xform,1);

% Make sure we have enough weights.
if size(prior_wt,1) ~= size(hp,2),
    prior_wt = repmat(prior_wt,size(hp,2),1);
end;

if strcmp(prior,'g0'),
    % Mean-0 Gaussian.
    val = -0.5*sum(prior_wt.*((hp').^2));
elseif strcmp(prior,'gamma'),
    % Gamma prior.
    alpha = gp.gamma_shape-1;
    beta = prior_wt;
    val = sum(alpha*log(hp') - beta.*hp');
elseif strcmp(prior,'logsparsity'),
    % Logarithmic sparsity penalty.
    val = -sum(log(prior_wt.*hp' + 1),1);
else
    val = 0;
end;
