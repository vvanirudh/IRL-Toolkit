% Warp feature coordinates according to the GP warping parameters.
function [l,m,ln,mn] = gpirlwarpx(x,warp_c,warp_l,warp_s,~)

% This is the logistic version.
warp_c = max(warp_c,1e-50); % This makes sure that x-warp_c is never 0.
if nargin < 5,
    % Compute warped coordinates.
    u = bsxfun(@rdivide,bsxfun(@minus,x,warp_c),warp_l);
    l = 1./(1+exp(-u));
    xwsqeu = 1./(2+exp(u)+exp(-u));
    % Compute partial derivatives with respect to x.
    m = bsxfun(@times,1./warp_l,xwsqeu);
    m(xwsqeu == 0) = 0;
    m = bsxfun(@plus,m,min(warp_s,1e100));
    m(isnan(m)) = 0;
    ln = [];
    mn = [];
else
    % Compute partial derivatives.
    u = bsxfun(@rdivide,bsxfun(@minus,x,warp_c),warp_l);
    xwsqeu = 1./(2+exp(u)+exp(-u));
    trp = 2./(exp(2*u)+3*exp(u)+3+exp(-u));
    dl = bsxfun(@rdivide,bsxfun(@minus,x,warp_c),-warp_l.^2);
    l = xwsqeu.*dl;
    l(xwsqeu == 0) = 0;
    m = bsxfun(@times,-1./warp_l,xwsqeu);
    m(xwsqeu == 0) = 0;
    dlol = bsxfun(@rdivide,dl,warp_l);
    lnt = dlol.*trp;
    lnd = -bsxfun(@plus,dlol,1./(warp_l.^2)).*xwsqeu;
    lnt(trp == 0) = 0;
    lnd(xwsqeu == 0) = 0;
    ln = lnt+lnd;
    mnt = bsxfun(@times,-1./(warp_l.^2),trp);
    mnd = bsxfun(@times,-1./(warp_l.^2),-xwsqeu);
    mnt(trp == 0) = 0;
    mnd(xwsqeu == 0) = 0;
    mn = mnt+mnd;
end;
