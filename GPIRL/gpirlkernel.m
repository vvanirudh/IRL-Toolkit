% Optimized kernel computation function for DC mode GPIRL.
function [K_uf,logDetAndPPrior,alpha,invK,dhp,dhpdr] = gpirlkernel(gp,y,Xstar)

% Constants.
dims = length(gp.inv_widths);
n = size(gp.X_u,1);

% Undo transforms.
inv_widths = gpirlhpxform(gp.inv_widths,[],gp.ard_xform,1); % This is \Lambda
noise_var = gpirlhpxform(gp.noise_var,[],gp.noise_xform,1); % This is 2\sigma^2
rbf_var = gpirlhpxform(gp.rbf_var,[],gp.rbf_xform,1); % This is \beta
if gp.warp_x,
    warp_c = gpirlhpxform(gp.warp_c,[],gp.warp_c_xform,1); % This is m
    warp_l = gpirlhpxform(gp.warp_l,[],gp.warp_l_xform,1); % This is \ell
    warp_s = gpirlhpxform(gp.warp_s,[],gp.warp_s_xform,1); % This is s
end;
inv_widths = min(inv_widths,1e100); % Prevent overflow.

% Compute scales.
iw_sqrt = sqrt(inv_widths);

% Scale positions in feature space.
if gp.warp_x,
    [X_u_warped,dxu] = gpirlwarpx(gp.X_u,warp_c,warp_l,warp_s);
    [X_f_warped,dxf] = gpirlwarpx(gp.X,warp_c,warp_l,warp_s);
    if nargin >= 3,
        [X_s_warped,dxs] = gpirlwarpx(Xstar,warp_c,warp_l,warp_s);
    end;
else
    X_u_warped = gp.X_u;
    X_f_warped = gp.X;
    if nargin >= 3,
        X_s_warped = Xstar;
    end;
end;
X_u_scaled = bsxfun(@times,iw_sqrt,X_u_warped);
X_f_scaled = bsxfun(@times,iw_sqrt,X_f_warped);

% Construct noise matrix.
mask_mat = ones(n)-eye(n);
if gp.warp_x,
    % Noise is spatially varying.
    dxu_scaled = -0.25*noise_var*bsxfun(@times,inv_widths,dxu);
    dxu_ssum = sum(dxu_scaled,2);
    nudist = bsxfun(@plus,dxu_ssum,dxu_ssum');
    nudist(~mask_mat) = 0;
    nmat = exp(nudist);
else
    % Noise is uniform.
    nconst = exp(-0.5*noise_var*sum(inv_widths));
    nmat = nconst*ones(n) + (1-nconst)*eye(n);
end;

% Compute K_uu matrix.
d_uu = bsxfun(@plus,sum(X_u_scaled.^2,2),sum(X_u_scaled.^2,2)') - 2*(X_u_scaled*(X_u_scaled'));
d_uu = max(d_uu,0);
K_uu = rbf_var*exp(-0.5*d_uu).*nmat;

if nargin < 3,
    % Compute K_uf matrix.
    d_uf = bsxfun(@plus,sum(X_u_scaled.^2,2),sum(X_f_scaled.^2,2)') - 2*(X_u_scaled*(X_f_scaled'));
    d_uf = max(d_uf,0);
    if gp.warp_x,
        % Noise is spatially varying.
        dxf_scaled = -0.25*noise_var*bsxfun(@times,inv_widths,dxf);
        dxf_ssum = sum(dxf_scaled,2);
        nfdist = bsxfun(@plus,dxu_ssum,dxf_ssum');
        K_uf = rbf_var*exp(-0.5*d_uf).*exp(nfdist);
    else
        % Noise is uniform.
        K_uf = nconst*rbf_var*exp(-0.5*d_uf);
    end;
else
    % Use Xstar to compute K_uf matrix.
    X_s_scaled = bsxfun(@times,iw_sqrt,X_s_warped);
    d_uf = bsxfun(@plus,sum(X_u_scaled.^2,2),sum(X_s_scaled.^2,2)') - 2*(X_u_scaled*(X_s_scaled'));
    d_uf = max(d_uf,0);
    if gp.warp_x,
        % Noise is spatially varying.
        dxs_scaled = -0.25*noise_var*bsxfun(@times,inv_widths,dxs);
        dxs_ssum = sum(dxs_scaled,2);
        nsdist = bsxfun(@plus,dxu_ssum,dxs_ssum');
        K_uf = rbf_var*exp(-0.5*d_uf).*exp(nsdist);
    else
        % Noise is uniform.
        K_uf = nconst*rbf_var*exp(-0.5*d_uf);
    end;
end;

% Invert the kernel matrix.
try
    [alpha,logDetAndPPrior,invK] = gpirlsafeinv(K_uu,y);
catch err
    % Save dump.
    save dump_file_chol;
    % Display the error.
    rethrow(err);
end;
K_ufKinv = K_uf'*invK;

% Add hyperparameter prior term which penalizes high partial correlation
% between inducing points.
logDetAndPPrior = logDetAndPPrior + 0.5*sum(sum(invK.^2));

if nargout > 3,
    % Compute gradients.
    hp_cnt = length(inv_widths)*(1+3*gp.warp_x) + gp.learn_noise + gp.learn_rbf;
    dhp = zeros(hp_cnt,1);
    dhpdr = zeros(hp_cnt,size(gp.X,1));
    
    % Pre-compute common matrices.
    inmat = (0.5*4*(invK^3) + alpha*alpha' - invK)';
    iwmat = inmat.*K_uu;

    % Compute gradient of inverse widths and warping parameters.
    if gp.warp_x,
        % Compute warp function derivatives.
        [lvec_u,mvec_u,lnvec_u,mnvec_u] = gpirlwarpx(gp.X_u,warp_c,warp_l,warp_s,X_u_warped);
        [lvec_f,mvec_f,lnvec_f,mnvec_f] = gpirlwarpx(gp.X,warp_c,warp_l,warp_s,X_f_warped);
    end;
    for i=1:dims,
        du = bsxfun(@plus,X_u_warped(:,i).^2,(X_u_warped(:,i).^2)') - 2*(X_u_warped(:,i)*(X_u_warped(:,i)'));
        df = bsxfun(@plus,X_u_warped(:,i).^2,(X_f_warped(:,i).^2)') - 2*(X_u_warped(:,i)*(X_f_warped(:,i)'));
        if gp.warp_x,
            % Noise is spatially varying.
            df = max(df,0)+0.5*noise_var*bsxfun(@plus,dxu(:,i),dxf(:,i)');
            du = max(du,0)+0.5*noise_var*bsxfun(@plus,dxu(:,i),dxu(:,i)').*mask_mat;
        else
            % Noise is uniform.
            df = max(df,0)+noise_var;
            du = max(du,0)+noise_var*mask_mat;
        end;
        
        % Compute gradient with respect to length-scales.
        dhp(i,1) = -0.25*sum(sum(iwmat.*du));
        if gp.warp_x,
            % Compute gradients with respect to warping parameters.
            diff_u = bsxfun(@minus,X_u_warped(:,i),X_u_warped(:,i)');
            lmat = diff_u.*bsxfun(@minus,lvec_u(:,i),lvec_u(:,i)');
            mmat = diff_u.*bsxfun(@minus,mvec_u(:,i),mvec_u(:,i)');
            lnmat = 0.25*noise_var*bsxfun(@plus,lnvec_u(:,i),lnvec_u(:,i)').*mask_mat;
            mnmat = 0.25*noise_var*bsxfun(@plus,mnvec_u(:,i),mnvec_u(:,i)').*mask_mat;
            snmat = (0.25*noise_var*2)*mask_mat;
            dhp(i+dims*1,1) = -0.5*inv_widths(i)*sum(sum(iwmat.*(lmat+lnmat)));
            dhp(i+dims*2,1) = -0.5*inv_widths(i)*sum(sum(iwmat.*(mmat+mnmat)));
            dhp(i+dims*3,1) = -0.5*inv_widths(i)*sum(sum(iwmat.*snmat));
        end;
        
        % Compute Jacobian of reward with respect to length-scales.
        % This is the component of the Jacobian from dK_uf'*alpha.
        dhpdr(i,:) = -0.5*sum(bsxfun(@times,df.*K_uf,alpha),1);
        % This is the component of the Jacobian from K_uf'*Kinv*dK*alpha.
        dhpdr(i,:) = dhpdr(i,:) + 0.5*(K_ufKinv*sum(bsxfun(@times,du.*K_uu,alpha'),2))';
        if gp.warp_x,
            % Compute gradients with respect to warping parameters.
            diff_f = bsxfun(@minus,X_u_warped(:,i),X_f_warped(:,i)');
            lfmat = bsxfun(@minus,lvec_u(:,i),lvec_f(:,i)');
            mfmat = bsxfun(@minus,mvec_u(:,i),mvec_f(:,i)');
            lnfmat = 0.25*noise_var*bsxfun(@plus,lnvec_u(:,i),lnvec_f(:,i)');
            mnfmat = 0.25*noise_var*bsxfun(@plus,mnvec_u(:,i),mnvec_f(:,i)');
            snfmat = 0.25*noise_var*2;
            % This is the component of the Jacobian from dK_uf'*alpha.
            dhpdr(i+dims*1,:) = -inv_widths(i)*sum(bsxfun(@times,(lfmat.*diff_f+lnfmat).*K_uf,alpha),1);
            dhpdr(i+dims*2,:) = -inv_widths(i)*sum(bsxfun(@times,(mfmat.*diff_f+mnfmat).*K_uf,alpha),1);
            dhpdr(i+dims*3,:) = -inv_widths(i)*sum(bsxfun(@times,snfmat.*K_uf,alpha),1);
            % This is the component of the Jacobian from K_uf'*Kinv*dK*alpha.
            dhpdr(i+dims*1,:) = dhpdr(i+dims*1,:) + inv_widths(i)*(K_ufKinv*sum(bsxfun(@times,(lmat+lnmat).*K_uu,alpha'),2))';
            dhpdr(i+dims*2,:) = dhpdr(i+dims*2,:) + inv_widths(i)*(K_ufKinv*sum(bsxfun(@times,(mmat+mnmat).*K_uu,alpha'),2))';
            dhpdr(i+dims*3,:) = dhpdr(i+dims*3,:) + inv_widths(i)*(K_ufKinv*sum(bsxfun(@times,snmat.*K_uu,alpha'),2))';
        end;
    end;
    idx = dims*(1+3*gp.warp_x)+1;
    
    % Compute gradient of variances.
    if gp.learn_noise,
        if gp.warp_x,
            % Compute gradient.
            dhp(idx,1) = (0.5/noise_var)*sum(sum(iwmat.*nudist.*mask_mat));
            % Compute reward Jacobian.
            % This is the component of the Jacobian from dK_uf'*alpha.
            dhpdr(idx,:) = (1/noise_var)*sum(bsxfun(@times,K_uf.*nfdist,alpha),1);
            % This is the component of the Jacobian from K_uf'*Kinv*dK*alpha.
            dhpdr(idx,:) = dhpdr(idx,:) - (1/noise_var)*(K_ufKinv*sum(bsxfun(@times,K_uu.*nudist.*mask_mat,alpha'),2))';
        else
            % Compute gradient.
            dhp(idx,1) = -0.25*sum(inv_widths)*sum(sum(iwmat.*mask_mat));
            % Compute reward Jacobian.
            % This is the component of the Jacobian from dK_uf'*alpha.
            dhpdr(idx,:) = -0.5*sum(inv_widths)*sum(bsxfun(@times,K_uf,alpha),1);
            % This is the component of the Jacobian from K_uf'*Kinv*dK*alpha.
            dhpdr(idx,:) = dhpdr(idx,:) + 0.5*sum(inv_widths)*(K_ufKinv*sum(bsxfun(@times,K_uu.*mask_mat,alpha'),2))';
        end;
        idx = idx+1;
    end;
    if gp.learn_rbf,
        % Compute gradient.
        dhp(idx,1) = (0.5/rbf_var)*sum(sum(iwmat));
        % Compute reward Jacobian.
        % This is the component of the Jacobian from dK_uf'*alpha.
        dhpdr(idx,:) = (1/rbf_var)*sum(bsxfun(@times,K_uf,alpha),1);
        % This is the component of the Jacobian from K_uf'*Kinv*dK*alpha.
        dhpdr(idx,:) = dhpdr(idx,:) - (1/rbf_var)*(K_ufKinv*sum(bsxfun(@times,K_uu,alpha'),2))';
        idx = idx+1;
    end;
    
    % Transform gradients.
    dhp(1:dims,1) = gpirlhpxform(gp.inv_widths,dhp(1:dims,1),gp.ard_xform,2);
    dhpdr(1:dims,:) = gpirlhpxform(gp.inv_widths,dhpdr(1:dims,:),gp.ard_xform,2);
    idx = dims+1;
    if gp.warp_x,
        dhp(idx:idx+dims-1,1) = gpirlhpxform(gp.warp_l,dhp(idx:idx+dims-1,1),gp.warp_l_xform,2);
        dhpdr(idx:idx+dims-1,:) = gpirlhpxform(gp.warp_l,dhpdr(idx:idx+dims-1,:),gp.warp_l_xform,2);
        idx = idx+dims;
        dhp(idx:idx+dims-1,1) = gpirlhpxform(gp.warp_c,dhp(idx:idx+dims-1,1),gp.warp_c_xform,2);
        dhpdr(idx:idx+dims-1,:) = gpirlhpxform(gp.warp_c,dhpdr(idx:idx+dims-1,:),gp.warp_c_xform,2);
        idx = idx+dims;
        dhp(idx:idx+dims-1,1) = gpirlhpxform(gp.warp_s,dhp(idx:idx+dims-1,1),gp.warp_s_xform,2);
        dhpdr(idx:idx+dims-1,:) = gpirlhpxform(gp.warp_s,dhpdr(idx:idx+dims-1,:),gp.warp_s_xform,2);
        idx = idx+dims;
    end;
    if gp.learn_noise,
        dhp(idx,1) = gpirlhpxform(gp.noise_var,dhp(idx,1),gp.noise_xform,2);
        dhpdr(idx,:) = gpirlhpxform(gp.noise_var,dhpdr(idx,:),gp.noise_xform,2);
        idx = idx+1;
    end;
    if gp.learn_rbf,
        dhp(idx,1) = gpirlhpxform(gp.rbf_var,dhp(idx,1),gp.rbf_xform,2);
        dhpdr(idx,:) = gpirlhpxform(gp.rbf_var,dhpdr(idx,:),gp.rbf_xform,2);
        idx = idx+1;
    end;
end;
