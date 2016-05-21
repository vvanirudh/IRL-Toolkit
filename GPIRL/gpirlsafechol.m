% Safe lower-triangular Cholesky decomposition with jitter added.
function L = gpirlsafechol(K)

% Keep boosting the diagonal.
p = 1;
jitter = 0;
while p ~= 0,
    if jitter == 0,
        [L,p] = chol(K,'lower');
        jitter = abs(mean(diag(K)))*1e-6;
    else
        warning(['Matrix is not positive definite, adding ' num2str(jitter) ' jitter!']);
        [L,p] = chol(K+eye(size(K,1))*jitter,'lower');
        jitter = jitter*10;
    end;
end;
