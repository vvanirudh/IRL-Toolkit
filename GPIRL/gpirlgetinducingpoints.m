% Get a good set of inducing states under the specified parameters.
function gp = gpirlgetinducingpoints(gp,~,mu_sa,algorithm_params)

% Constants.
states = size(mu_sa,1);
mu_s = sum(mu_sa,2);

if strcmp(algorithm_params.inducing_pts,'examples'),
    % Select just the example states.
    s_u = find(mu_s)';
elseif strcmp(algorithm_params.inducing_pts,'examplesplus'),
    % Select example states, plus random states to bring up to desired
    % total.
    s_u = find(mu_s)';
    if length(s_u) < algorithm_params.inducing_pts_count,
        other_states = find(~mu_s)';
        other_states = other_states(randperm(length(other_states)));
        s_u = [s_u other_states(...
            1:(algorithm_params.inducing_pts_count-length(s_u)))];
        s_u = sort(s_u);
    end;
elseif strcmp(algorithm_params.inducing_pts,'random'),
    % Select random states.
    s_u = randperm(states);
    s_u = sort(s_u(1:algorithm_params.inducing_pts_count));
else
    % Select all states.
    s_u = 1:states;
end;

% Set inducing points on the gp.
gp.s_u = s_u;
gp.X_u = gp.X(s_u,:);
