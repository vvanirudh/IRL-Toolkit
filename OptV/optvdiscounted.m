% Compute OptV objective and gradient. Discounted infinite-horizon version.
function [val,dv] = optvdiscounted(v,muE,ex_s,ex_a,mdp_data)

% Compute constants.
[states,actions,transitions] = size(mdp_data.sa_s);
[N,T] = size(ex_s);

% Compute diff - per-action probability.
g = mdp_data.discount*sum(mdp_data.sa_p.*v(mdp_data.sa_s),3);
gnorm = maxentsoftmax(g);
diff = bsxfun(@minus,g,gnorm);

% Compute objective.
val = sum(sum(diff(sub2ind(size(diff),ex_s,ex_a)),1),2);

% Invert for descent.
val = -val;

if nargout >= 2,
    % TODO: transform this into matrix operations.
    dv = zeros(states,1);
    %eg = exp(g-max(max(g)));
    for i=1:N,
        for t=1:T,
            s = ex_s(i,t);
            a = ex_a(i,t);
            
            % Get probability rows for each action.
            probs = zeros(states,actions);
            for act=1:actions,
                for k=1:transitions,
                    probs(mdp_data.sa_s(s,act,k),act) = ...
                        probs(mdp_data.sa_s(s,act,k),act) + ...
                        mdp_data.discount*mdp_data.sa_p(s,act,k);
                end;
            end;
            
            % Add up the rows.
            egs = exp(g(s,:)-max(g(s,:)));
            egn = sum(egs,2);
            dv = dv + probs(:,a) - sum(bsxfun(@times,probs,egs),2)/egn;
        end;
    end;
    
    if any(isnan(dv)) || any(isinf(dv)),
        fprintf(1,'1\n');
    end;
    
    % Invert for descent.
    dv = -dv;
end;
