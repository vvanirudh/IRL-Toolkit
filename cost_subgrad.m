function [cost] = cost_subgrad(w, lambda, F, Fmu, muE, L)
    cost = lambda/2 * norm(w, 1) + (F'*w + L)'*muE - Fmu'*w;
end