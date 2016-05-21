% Compute prior likelihood gradient of hyperparameters.
function dp = gpirlhppriorgrad(hp,prior,prior_wt,xform,gp)

% Transform.
orig_hp = hp;
hp = gpirlhpxform(hp,[],xform,1);

% Make sure we have enough weights.
if size(prior_wt,1) ~= size(hp,2),
    prior_wt = repmat(prior_wt,size(hp,2),1);
end;

if strcmp(prior,'g0'),
    % Mean-0 Gaussian.
    dp = -prior_wt.*(hp');
elseif strcmp(prior,'gamma'),
    % Gamma prior.
    alpha = gp.gamma_shape-1;
    beta = prior_wt;
    dp = (alpha./hp') - beta;
elseif strcmp(prior,'logsparsity'),
    % Logarithmic sparsity penalty.
    dp = -prior_wt.*(1./(prior_wt.*hp' + 1));
else
    dp = zeros(length(hp),1);
end;

% Transform back.
dp = gpirlhpxform(orig_hp,dp,xform,2);
