% Safe inversion of kernel matrix that uses SVD decomposition if Cholesky
% fails.
function [alpha,halfLogDet,invK] = gpirlsafeinv(K,y)

% First, try Cholesky.
[L,p] = chol(K,'lower');
if p == 0,
    alpha = L'\(L\y);
    halfLogDet = sum(log(diag(L)));
    invK = L'\(L\eye(size(K,1)));
else
    % Must do full SVD decomposition.
    warning('Cholesky failed, switching to SVD');
    [U,S,V] = svd(K);
    dS = diag(S);
    Sinv = diag(1./dS);
    alpha = V*(Sinv*(U'*y));
    halfLogDet = 0.5*sum(log(dS));
    invK = V*Sinv*U';
end;
