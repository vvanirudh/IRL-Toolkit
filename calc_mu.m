function [muE, ex_s, ex_a] = calc_mu(N, T, states, actions, example_samples, mdp_data)
    muE = zeros(states*actions,1);
    ex_s = zeros(N,T);
    ex_a = zeros(N,T);
    for i=1:N,
        for t=1:T,
            ex_s(i,t) = example_samples{i,t}(1);
            ex_a(i,t) = example_samples{i,t}(2);
            idx = (ex_s(i,t)-1)*actions+ex_a(i,t);
            muE(idx) = muE(idx) + mdp_data.discount^(t-1);
        end;
    end;
    muE = muE/N;
end