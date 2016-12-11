function [subgrad, mu_hat] = calc_subgrad(N, T, w, lambda, F, Fmu, L, mdp_data, mdp_model, ...
    test_params, r, states, actions)
    
    % 1-norm term
    first = zeros(size(w));
    first(w > 0) = lambda/2;
    first(w < 0) = -lambda/2;
    %first(abs(w) < 1e-10) = (-1 + 2 * rand()) * lambda/2;
    first(abs(w) < 1e-8) = 0;
   
    % solve MDP
    mdp_solution = feval(strcat(mdp_model,'solve'),mdp_data,r);
    
    % get samples
    example_samples = sampleexamples(mdp_model, mdp_data, mdp_solution, ...
        test_params);
    
    % get mu
    [muE, ~, ~] = calc_mu(N, T, states, actions, example_samples, mdp_data);
    
    % get delta-mu
    Fdelta_mu = F*muE - Fmu;
    
    % 2nd-term
    second = ( (F'*w + L)'*muE - Fmu'*w ) * Fdelta_mu;
    
    subgrad = first + second;
    mu_hat = muE;
end